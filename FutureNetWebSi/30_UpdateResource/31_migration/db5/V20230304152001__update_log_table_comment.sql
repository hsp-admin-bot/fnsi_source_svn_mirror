UPDATE "ntss"."log_table_comment"
SET
"ord_main_hst_ins_flg" = '1'
WHERE
	"tbl_name" = 'ord_main'
	AND "col_name" = 'addition_info';
