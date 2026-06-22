UPDATE
  sys_daily_no
SET
  current_no=/*sysDailyNo.currentNo*/'[{}]'::JSONB,
  is_disp=/*sysDailyNo.isDisp*/'',
  is_del=/*sysDailyNo.isDel*/'',
  up_date=/* sysDailyNo.upDate */''
WHERE
  ctl_no=/*sysDailyNo.ctlNo*/0
  and up_date = /* checkUpDate */'';
