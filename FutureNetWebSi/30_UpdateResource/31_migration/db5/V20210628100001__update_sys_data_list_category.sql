UPDATE ntss.sys_data_list_category
	SET disp_order=-1
	WHERE category_cd=157;
UPDATE ntss.sys_data_list_category
	SET disp_order=0
	WHERE category_cd=50;
INSERT INTO ntss.sys_data_list_category (category_cd,category_name,template_cd,disp_order)
	VALUES (158,'版数',5,1);