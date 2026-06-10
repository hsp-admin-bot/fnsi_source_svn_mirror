ALTER TABLE ntss.mst_comsv_setting ADD COLUMN fn_comsv_no numeric(10,0) DEFAULT NULL;
COMMENT ON COLUMN ntss.mst_comsv_setting.fn_comsv_no IS 'FNW+で管理する施設内の一意なコード';