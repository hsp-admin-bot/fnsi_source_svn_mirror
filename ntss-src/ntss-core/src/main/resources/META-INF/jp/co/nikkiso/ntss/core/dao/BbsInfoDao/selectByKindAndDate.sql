select
  /*%expand "A" */*
from
  bbs_info A
where
  A.facility_cd = /*facilityCd*/''
  and
  A.kind_no = /*kindNo*/0
  and
  -- mod FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 start
--   /*targetDate*/'' between to_char(A.notice_fac_cal_start_date, 'yyyyMMdd') and to_cahr(A.notice_fac_cal_end_date, 'yyyyMMdd')
  /*targetDate*/'' between to_date(A.notice_fac_cal_start_date, 'yyyyMMdd') and to_date(A.notice_fac_cal_end_date, 'yyyyMMdd')
  -- mod FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 end
  and
  A.is_del = '0'
  and
  A.is_disp = '1'
order by
  A.notice_fac_cal_start_date, A.bbs_ctl_no
;
