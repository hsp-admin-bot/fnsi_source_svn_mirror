ALTER TABLE ntss.sys_coop_no ADD coop_cd varchar(20) DEFAULT '' NOT NULL;
COMMENT ON COLUMN ntss.sys_coop_no.coop_cd IS '電文種別';
ALTER TABLE ntss.sys_coop_no ADD coop_cd_index varchar(10) DEFAULT '' NOT NULL;
COMMENT ON COLUMN ntss.sys_coop_no.coop_cd_index IS '付帯情報（電文）';