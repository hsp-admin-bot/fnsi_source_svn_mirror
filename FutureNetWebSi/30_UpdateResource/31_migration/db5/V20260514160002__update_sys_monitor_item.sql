DELETE FROM ntss.sys_monitor_item
WHERE moni_data_no='16';

INSERT INTO ntss.sys_monitor_item
(moni_data_no, moni_data_type, moni_data_name, moni_data_short_name, data_type, decimal_figure, unit, upper, lower, is_disp, vital_monitor_class, conv_item, reg_date, up_date)
VALUES('16', NULL, '血液入口〜静脈平均圧', '血静平均', 1, 0, 'mmHg', 600.00, -200.00, '1', '2', NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);