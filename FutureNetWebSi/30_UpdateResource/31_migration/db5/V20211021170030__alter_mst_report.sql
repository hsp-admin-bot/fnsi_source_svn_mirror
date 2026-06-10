ALTER TABLE mst_report ADD COLUMN report_setting jsonb;
COMMENT ON COLUMN mst_report."report_setting" IS '帳票設定';