UPDATE log_table_comment 
SET tbl_comment = '患者情報' 
WHERE
	tbl_name = 'pat_insurance' 
	OR tbl_name = 'pat_personal_main'