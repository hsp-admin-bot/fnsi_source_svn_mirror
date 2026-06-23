ALTER TABLE ntss.mst_monitor_graph ALTER COLUMN left_line_type_value TYPE varchar(10) USING left_line_type_value::varchar;
ALTER TABLE ntss.mst_monitor_graph ALTER COLUMN right_line_type_value TYPE varchar(10) USING right_line_type_value::varchar;
