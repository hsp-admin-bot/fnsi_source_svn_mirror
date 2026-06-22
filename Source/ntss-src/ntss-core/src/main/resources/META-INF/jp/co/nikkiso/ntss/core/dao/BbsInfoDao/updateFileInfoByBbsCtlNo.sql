update bbs_info
set
--  bbs_ctl_no = /* bbs.pat_id */null,
--  facility_cd = /* bbs.facility_cd */null,--
--  pat_info = /* bbs.pat_info */null,
--  staff_info = /* bbs.staff_info */null,
--  func_cd = /* bbs.func_cd */null,
--  kind_no = /* bbs.kind_no */null,
--  fn_seq_id = /* bbs.fn_seq_id */null,
--  content = /* bbs.content */null,
  file_info = /* bbs.file_info */null
--  notice_start_date = to_timestamp(/* bbs.notice_start_date */null, 'YYYY-MM-DD HH24:MI:SS'),
--  notice_end_date = to_timestamp(/* bbs.notice_end_date */null, 'YYYY-MM-DD HH24:MI:SS'),
--  reg_staff_id = /* bbs.reg_staff_id */null,
--  reg_staff_name = /* bbs.reg_staff_name */null,
--  upd_staff_id = /* bbs.upd_staff_id */null,
--  upd_staff_name = /* bbs.upd_staff_name */null,
--  transition_router_path = /* bbs.transition_router_path */null,
--  reg_date = to_timestamp(/* bbs.reg_date */null, 'YYYY-MM-DD HH24:MI:SS'),
--  up_date = to_timestamp(/* bbs.up_date */null, 'YYYY-MM-DD HH24:MI:SS'),
--  is_disp = /* bbs.is_disp */'1'
where
  bbs_ctl_no = /*bbs_ctl_no*/null
;