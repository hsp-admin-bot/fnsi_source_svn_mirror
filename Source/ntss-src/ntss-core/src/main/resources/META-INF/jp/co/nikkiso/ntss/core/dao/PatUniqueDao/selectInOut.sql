select
  a.pat_id,
  a.is_del,
  a.up_date,
  in_out_visit_history_info.ctl_no,
  in_out_visit_history_info.move_in_out,
  in_out_visit_history_info.in_out,
  in_out_visit_history_info.period_start,
  in_out_visit_history_info.period_end
 from
  pat_unique a
 cross join lateral
  jsonb_to_recordset(a.in_out_visit_history_info)
 as in_out_visit_history_info
 (
  ctl_no int,
  in_out text,
  disp_order int,
  period_start text,
  period_end text,
  move_in_out text,
  from_facility text,
  to_facility text,
  reason text,
--   add FNSI- 徐博 start
  facility_cd text
--   add FNSI- 徐博 end
 )
where
  a.is_del = '0'
/*%if null != facilityCdList && 0 != facilityCdList.size()*/
and
-- mod FNSI- 徐博 start
  in_out_visit_history_info.facility_cd in /* facilityCdList */('000001')
-- mod FNSI- 徐博 end
/*%end*/
/*%if null != patIdList && 0 != patIdList.size()*/
and
  pat_id in /* patIdList */(1)
/*%end*/
order by
  in_out_visit_history_info.period_start desc,
  in_out_visit_history_info.period_end asc,
  in_out_visit_history_info.ctl_no desc
;
