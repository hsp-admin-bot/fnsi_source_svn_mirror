INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)	
	VALUES (75,1,25,'日時','2','日時','2');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)	
	VALUES (76,2,25,'患者番号','2','患者番号','2');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)	
	VALUES (77,3,25,'患者氏名','2','患者氏名','2');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)	
	VALUES (78,1,26,'愁訴','2','愁訴','2');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)	
	VALUES (79,2,26,'処置','2','処置','2');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)	
	VALUES (80,3,26,'薬剤区分','2','薬剤区分','2');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)	
	VALUES (81,4,26,'処置薬剤分類','2','処置薬剤分類','2');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)	
	VALUES (82,5,26,'処置薬剤','2','処置薬剤','2');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)	
	VALUES (83,6,26,'数量','2','数量','2');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)	
	VALUES (84,7,26,'手技','2','手技','2');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)	
	VALUES (85,8,26,'処置者','2','処置者','2');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)	
	VALUES (86,1,27,'最高血圧','2','最高血圧','2');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)	
	VALUES (87,2,27,'最低血圧','2','最低血圧','2');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)	
	VALUES (88,3,27,'平均血圧','2','平均血圧','2');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)	
	VALUES (89,4,27,'脈拍','2','脈拍','2');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_name,function_display_type)	
	VALUES (90,5,27,'体温','2','体温','2');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,master_display_sql,function_display_name,function_display_type,function_display_sql)	
	VALUES (91,6,27,'[name]','1','select vital_monitor_item_cd as id, vital_monitor_item_name as name from mst_add_monitor where facility_cd = @facilityCd  and vital_monitor_class = ''1'' and is_del = ''0''','[name]','1','select vital_monitor_item_cd as id, vital_monitor_item_name as name from mst_add_monitor where facility_cd = @facilityCd  and vital_monitor_class = ''1'' and is_del = ''0''');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,master_display_sql,function_display_name,function_display_type,function_display_sql)	
	VALUES (92,1,28,'[name]','1','select moni_data_no as id, moni_data_name as name from sys_monitor_item ','[name]','1','select moni_data_no as id, moni_data_name as name from sys_monitor_item ');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,master_display_sql,function_display_name,function_display_type,function_display_sql)	
	VALUES (93,2,28,'[name]','1','select vital_monitor_item_cd as id, vital_monitor_item_name as name from mst_add_monitor where facility_cd = @facilityCd and vital_monitor_class = ''2'' and is_del = ''0''','[name]','1','select vital_monitor_item_cd as id, vital_monitor_item_name as name from mst_add_monitor where facility_cd = @facilityCd and vital_monitor_class = ''2'' and is_del = ''0''');
