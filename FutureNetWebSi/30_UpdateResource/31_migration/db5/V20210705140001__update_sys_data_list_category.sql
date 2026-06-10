
INSERT INTO ntss.sys_data_list_category (category_cd,category_name,template_cd,disp_order)
	VALUES (44,'既往歴',4,20);


INSERT INTO ntss.sys_data_list_category (category_cd,category_name,template_cd,disp_order)
	VALUES (35,'診療情報',4,11);


UPDATE ntss.sys_data_list_category
	SET category_name='透析困難'
	WHERE category_cd=34;



INSERT INTO ntss.sys_data_list_category (category_cd,category_name,template_cd,disp_order)
	VALUES (33,'重症度・搬送区分・車いす',4,9);



UPDATE ntss.sys_data_list_category
	SET category_name='保険情報・自費'
	WHERE category_cd=32;


UPDATE ntss.sys_data_list_category
	SET category_name='保険情報・セット'
	WHERE category_cd=31;


UPDATE ntss.sys_data_list_category
	SET category_name='保険情報・公費'
	WHERE category_cd=30;


UPDATE ntss.sys_data_list_category
SET category_name='保険情報・保険', template_cd=4, disp_order=5
WHERE category_cd=29;


INSERT INTO ntss.sys_data_list_category
(category_cd, category_name, template_cd, disp_order)
VALUES(28, '患者メモ', 4, 4);

INSERT INTO ntss.sys_data_list_category
(category_cd, category_name, template_cd, disp_order)
VALUES(25, '本人情報', 4, 1);

