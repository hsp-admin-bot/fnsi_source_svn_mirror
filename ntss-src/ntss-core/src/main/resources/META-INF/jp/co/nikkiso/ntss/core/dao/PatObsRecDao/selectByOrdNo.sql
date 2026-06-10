select
  A.obs_rec_no,
  A.pat_id,
  A.facility_cd,
  A.rec_date,
  A.up_cnt,
  A.kind_info,
  A.reg_staff_info,
  A.up_staff_info,
  A.obs_rec_info,
  A.bbs_ctl_no,
  A.ord_no,
  A.is_newest,
  A.is_del,
  A.fn_seq_id,
  to_char(A.rec_date, 'yyyy/MM/dd') as view_rec_date,
  to_char(A.rec_date, 'HH24:MI:SS') as view_rec_time,
  to_char(A.up_date, 'yyyy/MM/dd HH24:MI') as view_up_date
from
  pat_obs_rec A
where
  A.ord_no = /*ord_no*/1
/*%if ctl_no != null */
and
  A.obs_rec_no = /*ctl_no*/1
/*%end*/
/*%if kind_no != null */
and
  A.kind_info @> ('{"kind_no":' || /*kind_no*/null || '}')::jsonb
/*%end*/
/*%if is_del != null */
and
  A.is_del = /*is_del*/'0'
/*%end*/
/*%if is_newest != null */
and
  A.is_newest = /*is_newest*/'0'
/*%end*/
order by
  A.rec_date
;
