ALTER TABLE ntss.sys_facility ADD sys_facility_cd bigserial NOT NULL;
COMMENT ON COLUMN ntss.sys_facility.sys_facility_cd IS '全施設コード';