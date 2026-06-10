-- 血圧の data_type、upper が間違っているので修正
update
  sys_monitor_item
set
  conv_item = '{"0": "休止", "1": "洗消準備", "2": "洗消", "3": "溶解準備", "4": "溶解", "5": "原点復帰", "6": "手動操作", "7": "調整"}'
where
  moni_data_no = 'D1';
