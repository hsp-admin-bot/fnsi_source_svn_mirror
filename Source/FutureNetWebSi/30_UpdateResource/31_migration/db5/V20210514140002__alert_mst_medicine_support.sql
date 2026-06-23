ALTER TABLE ntss.mst_medicine_support ADD target_unit varchar(20) NULL;
COMMENT ON COLUMN ntss.mst_medicine_support.target_unit IS '検査値単位';