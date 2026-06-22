update pat_rad_main
set
  reg_rad_date = to_timestamp(/* params.get("afterDate")  */null || ' ' || to_char(reg_rad_date,'HH:MI:SS.MS'),'YYYY/MM/DD HH:MI:SS.MS') ,
  up_date = CURRENT_TIMESTAMP
where
  pat_id = /* params.get("patId") */null
and
  rad_result_cd = /* params.get("radResultCd") */null
and
  to_char(reg_rad_date,'YYYY/MM/DD') = /* params.get("beforeDate") */null
--   add FNSI-8247 劉全航 start
and
  is_del = '0'
  --   add FNSI-8247 劉全航 end
;
