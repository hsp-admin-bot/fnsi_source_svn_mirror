UPDATE log_table_comment
SET delete_flg = 1
WHERE tbl_name = 'mnt_mainte_main' AND col_name = 'mainte_ans_2';

UPDATE log_table_comment
SET delete_flg = 1
WHERE tbl_name = 'mnt_mainte_main' AND col_name = 'mainte_comment_2';
