UPDATE log_table_comment 
SET tbl_comment = '患者情報' 
WHERE
	tbl_name = 'pat_main' 
	OR tbl_name = 'pat_unique'