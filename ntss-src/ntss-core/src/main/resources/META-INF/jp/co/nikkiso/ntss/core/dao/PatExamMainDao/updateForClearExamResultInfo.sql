update pat_exam_main 
set
  exam_status = '0',
  result_exam_date = null,
  exam_result_info = null,
  up_date = CURRENT_TIMESTAMP
where
  exam_main_cd = /* examMainCd */null
;