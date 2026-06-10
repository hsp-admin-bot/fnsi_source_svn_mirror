--add 3009,分類不一致発生時条件送信設定
INSERT INTO ntss.sys_facility_setting ( facility_setting_no, setting_name, default_value, input_type, option_value, function_name, maker_setting, description, disp_order, reg_date, up_date, system_use_disp )
VALUES
	(
		'3009',
		'分類不一致発生時条件送信設定',
		'0',
		4,
		'[{"id":"0","name":"0:送信不可"},{"id":"1","name":"1:送信可能"}]',
		'体重計・条件送信',
		0,
		'薬剤、医療材料が分類不一致を発生した場合、条件送信の不可／可能を切り替えます',
		109,
		now( ),
		now( ),
		'3' 
	);