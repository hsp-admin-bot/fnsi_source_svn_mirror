ALTER TABLE ntss.ord_coop_no ADD coop_cd_index varchar(10) DEFAULT '' NOT NULL;
COMMENT ON COLUMN ntss.ord_coop_no.coop_cd_index IS '付帯情報（電文）';