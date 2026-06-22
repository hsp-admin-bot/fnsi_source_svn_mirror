update bbs_info
set
  is_disp = 0
where
  facility_cd = /*facilityCd*/NULL
AND
  bbs_ctl_no in /* bbsCtlNos */(0)
