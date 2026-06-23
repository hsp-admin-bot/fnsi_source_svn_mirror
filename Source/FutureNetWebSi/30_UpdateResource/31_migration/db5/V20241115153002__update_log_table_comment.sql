UPDATE log_table_comment
SET delete_flg = 1
WHERE tbl_name = 'mst_mainte_layout_group' AND col_name = 'layout_default';
