update pat_exam_main 
set
  reg_exam_date = CASE
    WHEN is_order = '0' THEN /* examDate */null -- 予定なし 結果更新時は検査日時を更新
    ELSE reg_exam_date
  END,
  exam_result_info = /* examResultInfo */null,
  up_date = CURRENT_TIMESTAMP,
  up_staff = /* upStaff */null,
  result_exam_date = /* examDate */null,
  reg_order_class = /* regOrderClass */null,
  exam_status = '1'
where
  exam_main_cd = /* examMainCd */null
;