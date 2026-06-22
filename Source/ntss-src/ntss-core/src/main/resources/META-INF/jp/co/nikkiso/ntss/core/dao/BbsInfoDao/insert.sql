insert into bbs_info (
  bbs_ctl_no,
  facility_cd,
  pat_info,
  staff_info,
  func_cd,
  kind_no,
  fn_seq_id,
  content,
  file_info,
  notice_start_date,
  notice_end_date,
  reg_staff_id,
  reg_staff_name,
  upd_staff_id,
  upd_staff_name,
  transition_router_path,
  reg_date,
  up_date,
  notice_fac_cal_start_date,
  notice_fac_cal_end_date,
  is_disp_bbs,
  color,
  title,
-- add FNSI-改修内容掲示板で文字色やサイズを変更したい 任 start
  html_content,
-- add FNSI-改修内容掲示板で文字色やサイズを変更したい 任 end
-- add FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 start
  notice_fac_cal_start_time,
  notice_fac_cal_end_time,
  is_time_start_flg,
  is_time_end_flg,
-- add FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 end
  reg_func_class,
--   add FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 start
  font_color
--   add FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 end
) values (
  /*bbs.bbs_ctl_no*/null,
  /*bbs.facility_cd*/null,
  /*bbs.pat_info*/null,
  /*bbs.staff_info*/null,
  /*bbs.func_cd*/null,
  /*bbs.kind_no*/null,
  /*bbs.fn_seq_id*/null,
  /*bbs.content*/null,
  '[]',
  -- mod FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 start
--   to_timestamp(/*bbs.notice_start_date*/null, 'YYYY-MM-DD HH24:MI:SS'),
--   to_timestamp(/*bbs.notice_end_date*/null, 'YYYY-MM-DD HH24:MI:SS'),
  /*bbs.notice_start_date*/null,
  /*bbs.notice_end_date*/null,
  -- mod FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 end
  /*bbs.reg_staff_id*/null,
  /*bbs.reg_staff_name*/null,
  /*bbs.upd_staff_id*/null,
  /*bbs.upd_staff_name*/null,
  /*bbs.transition_router_path*/null,
  to_timestamp(/* bbs.reg_date */null, 'YYYY-MM-DD HH24:MI:SS'),
  to_timestamp(/* bbs.up_date */null, 'YYYY-MM-DD HH24:MI:SS'),
-- mod FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 start
--   to_timestamp(/*bbs.notice_fac_cal_start_date*/null, 'YYYY-MM-DD HH24:MI:SS'),
--   to_timestamp(/*bbs.notice_fac_cal_end_date*/null, 'YYYY-MM-DD HH24:MI:SS'),
  /* bbs.notice_fac_cal_start_date */null,
  /* bbs.notice_fac_cal_end_date */null,
-- mod FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 end
  /*bbs.is_disp_bbs*/'0',
  /*bbs.color*/null,
  /*bbs.title*/null,
-- add FNSI-改修内容掲示板で文字色やサイズを変更したい 任 start
  /*bbs.html_content*/null,
-- add FNSI-改修内容掲示板で文字色やサイズを変更したい 任 end
-- add FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 start
  /* bbs.notice_fac_cal_start_time */null,
  /* bbs.notice_fac_cal_end_time */null,
  /*bbs.is_time_start_flg*/'0',
  /*bbs.is_time_end_flg*/'0',
-- add FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 end
  /*bbs.reg_func_class*/null,
  --   add FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 start
  /*bbs.font_color*/null
  --  add FNSI-436 改修内容 色選択の選択されているものがわかりにくい 趙立強 end
);
