-- mst_test_mode2 へのサンプルデータ追加
INSERT INTO mst_test_mode2(facility_cd,mode2_name,reg_date,up_date) VALUES 
	('009997','テスト1','2019/01/31 15:50:20.524','2019/01/31 15:50:20.524'),
	('009997','テスト2','2019/01/31 15:50:20.524','2019/01/31 15:50:20.524');

-- sys_master_define のデータ追加
INSERT INTO sys_master_define(master_physical_name,master_name,disp_class,mode,allow_sort,allow_add_record,disp_order,column_info,combo_data,reg_date,up_date,reference_combo_def) VALUES
	 ('mst_test_mode2','独自マスタ','2','2',null,null,7,null,null,null,null,null);
