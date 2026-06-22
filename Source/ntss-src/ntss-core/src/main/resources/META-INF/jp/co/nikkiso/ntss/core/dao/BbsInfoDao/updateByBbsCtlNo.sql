update bbs_info
set
--  bbs_ctl_no = /* bbs.pat_id */null,
--  facility_cd = /* bbs.facility_cd */null,
  pat_info = /* bbs.pat_info */null,
  staff_info = /* bbs.staff_info */null,
--  func_cd = /* bbs.func_cd */null,
  kind_no = /* bbs.kind_no */null,
--  fn_seq_id = /* bbs.fn_seq_id */null,
  content = /* bbs.content */null,
-- add FNSI-改修内容掲示板で文字色やサイズを変更したい 任 start
  html_content = /* bbs.html_content */null,
-- add FNSI-改修内容掲示板で文字色やサイズを変更したい 任 end
--  file_info = /* bbs.file_info */null,
-- mod FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 start
--   notice_start_date = to_timestamp(/* bbs.notice_start_date */null, 'YYYY-MM-DD HH24:MI:SS'),
--   notice_end_date = to_timestamp(/* bbs.notice_end_date */null, 'YYYY-MM-DD HH24:MI:SS'),
  notice_start_date = /* bbs.notice_start_date */null,
  notice_end_date = /* bbs.notice_end_date */null,
-- mod FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 end
--  reg_staff_id = /* bbs.reg_staff_id */null,
--  reg_staff_name = /* bbs.reg_staff_name */null,
  upd_staff_id = /* bbs.upd_staff_id */null,
  upd_staff_name = /* bbs.upd_staff_name */null,
  transition_router_path = /* bbs.transition_router_path */null,
  --reg_date = to_timestamp(/* bbs.reg_date */null, 'YYYY-MM-DD HH24:MI:SS'),
  up_date = to_timestamp(/* bbs.up_date */null, 'YYYY-MM-DD HH24:MI:SS'),
  -- mod FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 start
--   notice_fac_cal_start_date = to_timestamp(/* bbs.notice_fac_cal_start_date */null, 'YYYY-MM-DD HH24:MI:SS'),
--   notice_fac_cal_end_date = to_timestamp(/* bbs.notice_fac_cal_end_date */null, 'YYYY-MM-DD HH24:MI:SS'),
  notice_fac_cal_start_date = /* bbs.notice_fac_cal_start_date */null,
  notice_fac_cal_end_date = /* bbs.notice_fac_cal_end_date */null,
  -- mod FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 end
  is_disp_bbs = /* bbs.is_disp_bbs */'0',
  color = /* bbs.color */null,
  title = /* bbs.title */null,
  -- add FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 start
  notice_fac_cal_start_time = /* bbs.notice_fac_cal_start_time */null,
  notice_fac_cal_end_time = /* bbs.notice_fac_cal_end_time */null,
  is_time_start_flg = /* bbs.is_time_start_flg */'0',
  is_time_end_flg = /* bbs.is_time_end_flg */'0',
  -- add FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 end
--  is_disp = /* bbs.is_disp */'1'
--   add FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 start
    font_color = /* bbs.font_color */null
--   add FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 end
where
  bbs_ctl_no = /*bbs_ctl_no*/null
;
