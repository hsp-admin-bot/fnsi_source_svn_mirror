UPDATE sys_report_class 
SET report_type = '[{"cd": "0", "name": "シングル"}, {"cd": "1", "name": "マルチ"}]' 
WHERE
	report_class_name = '装置帳票'
	AND report_class_cd = 7;