update bbs_info
set
  notice_start_date = to_char((to_date(notice_start_date,'yyyymmdd') + interval '1 day' *  /*dataNumber*/0)	,'yyyymmdd'),
  notice_end_date = to_char((to_date(notice_end_date,'yyyymmdd') + interval '1 day' *  /*dataNumber*/0)	,'yyyymmdd')
where
  bbs_ctl_no = /*bbsCtlNo*/null
