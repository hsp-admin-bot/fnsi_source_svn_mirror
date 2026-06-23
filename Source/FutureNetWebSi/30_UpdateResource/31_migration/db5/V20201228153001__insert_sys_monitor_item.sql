/* 【モニタバイタルグラフ】	※ 対象：長期、短期
	下記項目を選択対象に追加
	・	透析前最高血圧
	・	透析前最低血圧
	・	透析前平均血圧
	・	透析後最高血圧
	・	透析後最低血圧
	・	透析後平均血圧 */
INSERT INTO sys_monitor_item ( moni_data_no, moni_data_name, moni_data_short_name, data_type, decimal_figure, UPPER, LOWER, is_disp, vital_monitor_class, reg_date, up_date )
VALUES
	( '112', '透析前最高血圧', '透析前最高血圧', 3, 0, 100.00, 0.00, '1', '2', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP );
INSERT INTO sys_monitor_item ( moni_data_no, moni_data_name, moni_data_short_name, data_type, decimal_figure, UPPER, LOWER, is_disp, vital_monitor_class, reg_date, up_date )
VALUES
	( '113', '透析前最低血圧', '透析前最低血圧', 3, 0, 100.00, 0.00, '1', '2', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP );
INSERT INTO sys_monitor_item ( moni_data_no, moni_data_name, moni_data_short_name, data_type, decimal_figure, UPPER, LOWER, is_disp, vital_monitor_class, reg_date, up_date )
VALUES
	( '114', '透析前平均血圧', '透析前平均血圧', 3, 0, 100.00, 0.00, '1', '2', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP );
INSERT INTO sys_monitor_item ( moni_data_no, moni_data_name, moni_data_short_name, data_type, decimal_figure, UPPER, LOWER, is_disp, vital_monitor_class, reg_date, up_date )
VALUES
	( '115', '透析後最高血圧', '透析後最高血圧', 3, 0, 100.00, 0.00, '1', '2', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP );
INSERT INTO sys_monitor_item ( moni_data_no, moni_data_name, moni_data_short_name, data_type, decimal_figure, UPPER, LOWER, is_disp, vital_monitor_class, reg_date, up_date )
VALUES
	( '116', '透析後最低血圧', '透析後最低血圧', 3, 0, 100.00, 0.00, '1', '2', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP );
INSERT INTO sys_monitor_item ( moni_data_no, moni_data_name, moni_data_short_name, data_type, decimal_figure, UPPER, LOWER, is_disp, vital_monitor_class, reg_date, up_date )
VALUES
	( '117', '透析後平均血圧', '透析後平均血圧', 3, 0, 100.00, 0.00, '1', '2', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP );