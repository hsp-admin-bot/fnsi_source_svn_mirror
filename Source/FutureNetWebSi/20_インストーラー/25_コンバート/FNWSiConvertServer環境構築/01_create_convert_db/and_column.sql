ALTER table mst_take_medicine ADD COLUMN fn_take_medicine_cd varchar(3) DEFAULT null;
ALTER table ord_prescription ADD COLUMN  fn_ord_prescription_no varchar(50) DEFAULT null;

ALTER TABLE mst_monitor_graph ALTER COLUMN left_graph_lower_limit TYPE decimal ( 10, 2 );
ALTER TABLE mst_monitor_graph ALTER COLUMN right_graph_lower_limit TYPE decimal( 10, 2 );
ALTER TABLE mst_monitor_graph ALTER COLUMN left_graph_upper_limit TYPE decimal ( 10, 2 );
ALTER TABLE mst_monitor_graph ALTER COLUMN right_graph_upper_limit TYPE decimal( 10, 2 );


