-- 項目変更
ALTER TABLE pat_main
 ALTER COLUMN in_out_current_state type character varying(2),
 ALTER COLUMN in_out_plan_state type character varying(2);
