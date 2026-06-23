UPDATE sys_report_class 
SET report_type = '[{"cd": "1", "name": "単患者帳票"}, {"cd": "2", "name": "処方帳票"}]' 
WHERE 
	report_class_name = '単患者帳票' 
	AND report_class_cd = 2;
