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
from pat_obs_rec A
where A.obs_rec_no = /*ctlNo*/1 and A.pat_id = /*patId*/1
;