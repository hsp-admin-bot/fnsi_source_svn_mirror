-- データリストレイアウト追加（集計（日別）、（月別））
INSERT INTO ntss.sys_data_list_category (category_cd,category_name,template_cd,disp_order)
	VALUES (132,'加算算定件数',1,13);
INSERT INTO ntss.sys_data_list_category (category_cd,category_name,template_cd,disp_order)
	VALUES (133,'加算算定件数',2,13);

-- 装置情報（点検（日常・定期））
INSERT INTO ntss.sys_data_list_category (category_cd,category_name,template_cd,disp_order)
	VALUES (134,'日常点検',9,1);
INSERT INTO ntss.sys_data_list_category (category_cd,category_name,template_cd,disp_order)
	VALUES (135,'定期点検',9,2);
INSERT INTO ntss.sys_data_list_category (category_cd,category_name,template_cd,disp_order)
	VALUES (136,'定期/日常欄表示',9,3);
INSERT INTO ntss.sys_data_list_category (category_cd,category_name,template_cd,disp_order)
	VALUES (137,'集計項目',9,4);

-- 装置情報（水質検査）
INSERT INTO ntss.sys_data_list_category (category_cd,category_name,template_cd,disp_order)
	VALUES (138,'表示',10,1);
INSERT INTO ntss.sys_data_list_category (category_cd,category_name,template_cd,disp_order)
	VALUES (139,'装置情報',10,2);
INSERT INTO ntss.sys_data_list_category (category_cd,category_name,template_cd,disp_order)
	VALUES (140,'検査種別出力対象',10,3);
INSERT INTO ntss.sys_data_list_category (category_cd,category_name,template_cd,disp_order)
	VALUES (141,'表示項目',10,4);

-- 装置情報（自己診断）
INSERT INTO ntss.sys_data_list_category (category_cd,category_name,template_cd,disp_order)
	VALUES (142,'表示',11,1);
INSERT INTO ntss.sys_data_list_category (category_cd,category_name,template_cd,disp_order)
	VALUES (143,'装置情報',11,2);
INSERT INTO ntss.sys_data_list_category (category_cd,category_name,template_cd,disp_order)
	VALUES (144,'配管自己診断',11,3);
INSERT INTO ntss.sys_data_list_category (category_cd,category_name,template_cd,disp_order)
	VALUES (145,'漏血自己診断',11,4);
INSERT INTO ntss.sys_data_list_category (category_cd,category_name,template_cd,disp_order)
	VALUES (146,'透析液液量自己診断',11,5);
INSERT INTO ntss.sys_data_list_category (category_cd,category_name,template_cd,disp_order)
	VALUES (147,'濃度自己診断',11,6);