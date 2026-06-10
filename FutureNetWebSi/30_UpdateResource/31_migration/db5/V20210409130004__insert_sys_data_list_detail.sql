INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,master_display_sql,function_display_name,function_display_type,function_display_sql)
	VALUES (1384,1,148,'[name]','1','select survey_point_cd as id, point_name as name from mst_water_survey_point where facility_cd = @facilityCd AND is_del = ''0''','[name]','1','select survey_point_cd as id, point_name as name from mst_water_survey_point where facility_cd = @facilityCd AND is_del = ''0''');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)
	VALUES (1385,1,149,'装置名','2','装置名','2');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)
	VALUES (1386,2,149,'製造番号','2','製造番号','2');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)
	VALUES (1387,1,150,'型式','2','型式','2');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)
	VALUES (1388,2,150,'ベッド名','2','ベッド名','2');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)
	VALUES (1389,3,150,'設置日','2','設置日','2');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,master_display_sql,function_display_name,function_display_type,function_display_sql)
	VALUES (1390,1,151,'[name]','1','select mainte_layout_cd as id, layout_name as name from mst_mainte_layout where facility_cd = @facilityCd AND is_del = ''0''','[name]','1','select mainte_layout_cd as id, layout_name as name from mst_mainte_layout where facility_cd = @facilityCd AND is_del = ''0''');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,master_display_sql,function_display_name,function_display_type,function_display_sql)
	VALUES (1391,1,152,'[name]','1','select mainte_layout_group_cd as id, group_name as name from mst_mainte_layout_group where facility_cd = @facilityCd AND is_del = ''0''','[name]','1','select mainte_layout_group_cd as id, group_name as name from mst_mainte_layout_group where facility_cd = @facilityCd AND is_del = ''0''');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)
	VALUES (1392,1,153,'定期/日常','2','定期/日常','2');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)
	VALUES (1393,1,154,'点検記録簿','2','点検記録簿','2');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)
	VALUES (1394,2,154,'交換部品記録簿','2','交換部品記録簿','2');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)
	VALUES (1395,1,155,'項目1（定期・日常共通）','2','項目1（定期・日常共通）','2');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)
	VALUES (1396,2,155,'項目2（定期・日常共通）','2','項目2（定期・日常共通）','2');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)
	VALUES (1397,3,155,'項目3（定期のみ）','2','項目3（定期のみ）','2');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)
	VALUES (1398,1,156,'実施者（定期・日常共通）','2','実施者（定期・日常共通）','2');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)
	VALUES (1399,2,156,'確認者（定期のみ）','2','確認者（定期のみ）','2');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)
	VALUES (1400,3,156,'点検結果（定期・日常共通）','2','点検結果（定期・日常共通）','2');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)
	VALUES (1401,4,156,'点検記録番号（定期のみ）','2','点検記録番号（定期のみ）','2');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)
	VALUES (1402,5,156,'点検コメント（日常のみ）','2','点検コメント（日常のみ）','2');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)
	VALUES (1403,6,156,'補足コメント（定期・日常共通）','2','補足コメント（定期・日常共通）','2');