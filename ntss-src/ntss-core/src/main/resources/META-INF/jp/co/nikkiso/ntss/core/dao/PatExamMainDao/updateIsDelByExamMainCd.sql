update pat_exam_main
set
  is_del = '1',
  up_staff = /* upStaff */null,
  up_date = CURRENT_TIMESTAMP
where
  exam_main_cd = /* examMainCd */null
;