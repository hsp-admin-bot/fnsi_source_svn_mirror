-- 血圧の data_type、upper が間違っているので修正
update
  sys_monitor_item
set
  data_type = 1, upper = 300.00, up_date = now()
where
  moni_data_no in ('110', '111', '112', '113', '114', '115', '116', '117');
