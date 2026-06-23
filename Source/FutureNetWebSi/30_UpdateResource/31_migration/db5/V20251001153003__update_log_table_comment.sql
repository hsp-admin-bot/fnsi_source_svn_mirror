UPDATE ntss.log_table_comment SET col_comment='UFR警報点上限' WHERE tbl_name='mst_dialyzer' and col_name='ufr_warning_max';
UPDATE ntss.log_table_comment SET col_comment='UFR警報点下限' WHERE tbl_name='mst_dialyzer' and col_name='ufr_warning_min';
