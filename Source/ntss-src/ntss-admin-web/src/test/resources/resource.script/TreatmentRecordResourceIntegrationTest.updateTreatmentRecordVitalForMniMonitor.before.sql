-- updateTreatmentRecordVitalForMniMonitorのupdateのテスト用にシーケンス番号の開始を1000に変更
INSERT INTO mni_monitor
(ord_no, data_type, facility_cd, monitor_data, occur_date, reg_date, is_del) VALUES
  (10000, 2, 'nkknkk', '{"90": "128"}', '2019/11/21 12:00:00.000','2019/11/21 12:00:00.000', '0');
