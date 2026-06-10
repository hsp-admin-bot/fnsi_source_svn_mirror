select
  pu.pat_id as pat_id,
  pm.facility_cd as facility_cd,
  in_out_visit_history_info.ctl_no as ctl_no,
  in_out_visit_history_info.move_in_out as move_in_out,
  in_out_visit_history_info.in_out as in_out,
  in_out_visit_history_info.period_start as period_start
from
  pat_unique pu
Inner join
  pat_main pm
on
  pu.pat_id = pm.pat_id
cross join lateral
  jsonb_to_recordset(pu.in_out_visit_history_info) as in_out_visit_history_info
(
  ctl_no int,
  in_out text,
  disp_order int,
  period_start text,
  period_end text,
  move_in_out text
)
Inner join (
  select 
    pat_id,
    Max(in_out_visit_history_info2.ctl_no) as ctl_no
  from
    pat_unique
  cross join lateral
    jsonb_to_recordset(in_out_visit_history_info) as in_out_visit_history_info2
    (
      ctl_no int,
      in_out text,
      period_start text
    )
    where
      is_del = '0'
    /*%if pat_id_list.size() != 0 */
    and
      pat_id in /* pat_id_list */(null)
    /*%end */
    and
      in_out_visit_history_info2.period_start = /* targetDt */'99991231'
    and
      in_out_visit_history_info2.in_out IS NOT NULL
    group by 
      pat_id
) As inOutInfoB
on
  pu.pat_id = inOutInfoB.pat_id
and
  in_out_visit_history_info.ctl_no = inOutInfoB.ctl_no
where
  pu.is_del = '0'
/*%if pat_id_list.size() != 0 */
and
  pu.pat_id in /* pat_id_list */(null)
/*%end */
and
  in_out_visit_history_info.period_start = /* targetDt */'99991231'
Order By 
  pu.pat_Id
