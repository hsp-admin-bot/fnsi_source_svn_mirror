update pat_exam_main
set 
  data_gen_class = '0',
  result_exam_date = null,
  exam_result_info = null,
  exam_status = '0',
  up_date = CURRENT_TIMESTAMP,
  up_staff = /* upStaff */null
where
  exam_main_cd = /* examMainCd */null
;