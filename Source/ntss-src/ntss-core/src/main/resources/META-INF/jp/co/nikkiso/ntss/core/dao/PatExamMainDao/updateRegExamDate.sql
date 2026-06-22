update pat_exam_main
set
  reg_exam_date = to_timestamp(/* params.get("afterDate")  */null || ' ' || to_char(reg_exam_date,'HH:MI:SS.MS'),'YYYY/MM/DD HH:MI:SS.MS') ,
  up_date = CURRENT_TIMESTAMP
where
  pat_id = /* params.get("patId") */null
and
  to_char(reg_exam_date,'YYYY/MM/DD') = /* params.get("beforeDate") */null
--   add FNSI 425 姜
and
  exam_status = '0'
;
