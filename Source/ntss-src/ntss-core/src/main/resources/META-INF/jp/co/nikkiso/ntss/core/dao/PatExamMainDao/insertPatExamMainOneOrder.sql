insert into pat_exam_main
 (pat_id,
  facility_cd,
  reg_exam_date,
  reg_order_class,
  ord_no,
  exam_status,
  data_gen_class,
  result_exam_date,
  exam_result_info,
  reg_date,
  reg_staff,
  up_date,
  up_staff
)
values
  (/*param.patId*/1,
  /*param.facilityCd*/'000001',
  /*param.regExamDate*/'1970/01/01 00:00:00',
  /*param.regOrderClass*/'1',
  /*param.ordNo*/0,
  '1',
  '0',
  /*param.resultExamDate*/'1970/01/01 00:00:00',
  /*param.examResultInfo*/'[]',
  CURRENT_TIMESTAMP,
  /*param.regStaff*/'',
  CURRENT_TIMESTAMP,
  /*param.upStaff*/''
)
;