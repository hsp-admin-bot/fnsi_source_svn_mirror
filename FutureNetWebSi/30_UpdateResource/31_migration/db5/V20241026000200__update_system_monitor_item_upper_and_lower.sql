--透析液温度警報点（上限）
--透析温上
UPDATE ntss.sys_monitor_item SET decimal_figure=1, upper=999.00, lower=0.00,  up_date=current_timestamp WHERE moni_data_no='60';

--透析液温度警報点（下限）
--透析温下
UPDATE ntss.sys_monitor_item SET decimal_figure=1, upper=999.00, lower=0.00,  up_date=current_timestamp WHERE moni_data_no='61';

--補液温度設定値
--補液温設
UPDATE ntss.sys_monitor_item SET decimal_figure=1, upper=400.00, lower=300.00,  up_date=current_timestamp WHERE moni_data_no='75';