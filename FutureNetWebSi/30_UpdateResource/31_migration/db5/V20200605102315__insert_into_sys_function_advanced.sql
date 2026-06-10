DELETE FROM sys_function_advanced WHERE function_adv_cd = 'A09';

INSERT INTO sys_function_advanced(
	function_adv_cd,
	function_adv_name,
	disp_order,
	is_disp,
	is_del,
	reg_date,
	up_date
)
VALUES(
	'A09',
	'患者イベントスコア',
	9,
	1,
	0,
	now(),
	now()
);
