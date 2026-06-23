-- #11124 酸素飽和度対応
-- モニタデータ追加
DELETE from ntss.sys_monitor_item where moni_data_no = '104';
DELETE from ntss.sys_monitor_item where moni_data_no = '105';

INSERT INTO ntss.sys_monitor_item
  (moni_data_no, moni_data_type, moni_data_name, moni_data_short_name, data_type, decimal_figure, unit, upper, lower, is_disp, vital_monitor_class, conv_item, reg_date, up_date)
  VALUES('104', NULL, 'ΔSO2', 'ΔSO2', 1, 1, '％', 300.00, -300.00, '1', '2', NULL, now(), now());
INSERT INTO ntss.sys_monitor_item
  (moni_data_no, moni_data_type, moni_data_name, moni_data_short_name, data_type, decimal_figure, unit, upper, lower, is_disp, vital_monitor_class, conv_item, reg_date, up_date)
  VALUES('105', NULL, '補正ΔSO2', '補正ΔSO2', 1, 1, '％', 1000.00, 700.00, '1', '2', NULL, now(), now());
