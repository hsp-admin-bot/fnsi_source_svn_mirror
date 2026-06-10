-- データリストレイアウト追加（集計（日別）、（月別））
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,master_display_sql,function_display_name,function_display_type,function_display_sql,data_set,cell_display)
	VALUES (1348,1,132,'[name]','1','select addition_cd as id, addition_name as name from mst_addition where facility_cd = @facilityCd AND is_del = ''0''','[name]','1','select addition_cd as id, addition_name as name from mst_addition where facility_cd = @facilityCd AND is_del = ''0''','[{"param": "count", "sql_cd": -11039}]','[count] 件');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,master_display_sql,function_display_name,function_display_type,function_display_sql,data_set,cell_display)
	VALUES (1349,1,133,'[name]','1','select addition_cd as id, addition_name as name from mst_addition where facility_cd = @facilityCd AND is_del = ''0''','[name]','1','select addition_cd as id, addition_name as name from mst_addition where facility_cd = @facilityCd AND is_del = ''0''','[{"param": "count", "sql_cd": -11039}]','[count] 件');

-- 装置情報（点検（日常・定期））
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,master_display_sql,function_display_name,function_display_type,function_display_sql,data_set,cell_display)
	VALUES (1350,1,134,'[name]','1','select mainte_layout_cd as id, layout_name as name from mst_mainte_layout where facility_cd = @facilityCd AND is_del = ''0''','[name]','1','select mainte_layout_cd as id, layout_name as name from mst_mainte_layout where facility_cd = @facilityCd AND is_del = ''0''','[{"param": "count", "sql_cd": -11039}]','[count] 件');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,master_display_sql,function_display_name,function_display_type,function_display_sql,data_set,cell_display)
	VALUES (1351,1,135,'[name]','1','select mainte_category_cd as id, category_name as name from mst_mainte_category where facility_cd = @facilityCd AND is_del = ''0''','[name]','1','select mainte_category_cd as id, category_name as name from mst_mainte_category where facility_cd = @facilityCd AND is_del = ''0''','[{"param": "count", "sql_cd": -11039}]','[count] 件');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_type)
	VALUES (1352,1,136,'表示','2','1');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_type)
	VALUES (1353,1,137,'装置台数','2','1');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_type)
	VALUES (1354,2,137,'合格台数','2','1');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_type)
	VALUES (1355,3,137,'不合格台数','2','1');

-- 装置情報（水質検査）
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_type)
	VALUES (1356,1,138,'装置名','2','1');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_type)
	VALUES (1357,2,138,'製造番号','2','1');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_type)
	VALUES (1358,1,139,'型式','2','1');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_type)
	VALUES (1359,2,139,'ベッド名','2','1');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_type)
	VALUES (1360,3,139,'設置日','2','1');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,master_display_sql,function_display_type,function_display_sql,data_set,cell_display)
	VALUES (1361,3,140,'[name]','1','select survey_type_cd as id, survey_type_name as name from mst_water_survey_type where facility_cd = @facilityCd AND is_del = ''0''','1','select survey_type_cd as id, survey_type_name as name from mst_water_survey_type where facility_cd = @facilityCd AND is_del = ''0''','[{"param": "count", "sql_cd": -11039}]','[count] 件');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_type)
	VALUES (1362,1,141,'採取時刻','2','1');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_type)
	VALUES (1363,2,141,'結果','2','1');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_type)
	VALUES (1364,3,141,'採取者','2','1');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_type)
	VALUES (1365,4,141,'検査者','2','1');

-- 装置情報（自己診断）
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_type)
	VALUES (1366,1,142,'装置名','2','1');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_type)
	VALUES (1367,2,142,'製造番号','2','1');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_type)
	VALUES (1368,1,143,'型式','2','1');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_type)
	VALUES (1369,2,143,'ベッド名','2','1');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_type)
	VALUES (1370,3,143,'設置日','2','1');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_type)
	VALUES (1371,1,144,'配管自己診断結果','2','1');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_type)
	VALUES (1372,2,144,'配管漏れ（陰圧）','2','1');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_type)
	VALUES (1373,3,144,'配管漏れ（陽圧）','2','1');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_type)
	VALUES (1374,4,144,'除水テスト','2','1');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_type)
	VALUES (1375,5,144,'バランステスト','2','1');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_type)
	VALUES (1376,6,144,'CF漏れ','2','1');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_type)
	VALUES (1377,7,144,'CF2漏れ','2','1');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_type)
	VALUES (1378,1,145,'赤電圧','2','1');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_type)
	VALUES (1379,2,145,'緑電圧','2','1');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_type)
	VALUES (1380,1,146,'透析液流量','2','1');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_type)
	VALUES (1381,1,147,'濃度自己診断結果','2','1');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_type)
	VALUES (1382,2,147,'透析液濃度','2','1');
INSERT INTO ntss.sys_data_list_detail (data_list_detail_cd,disp_order,category_cd,master_display_name,master_display_type,function_display_type)
	VALUES (1383,3,147,'B原液濃度','2','1');
