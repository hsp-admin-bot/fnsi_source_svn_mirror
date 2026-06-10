ALTER TABLE ntss.mst_facility ADD system_use_setting varchar(1) NULL DEFAULT '1'::character varying;
COMMENT ON COLUMN ntss.mst_facility.system_use_setting IS 'システム利用設定';