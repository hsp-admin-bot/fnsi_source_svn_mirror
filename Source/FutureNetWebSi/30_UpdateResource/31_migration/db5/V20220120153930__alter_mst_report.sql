ALTER TABLE mst_report ADD COLUMN multi_total_defaul varchar;
COMMENT ON COLUMN mst_report."multi_total_defaul" IS '集計のデフォルトの値';