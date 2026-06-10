DROP INDEX IF EXISTS idx_mst_comp_treatment_01;
CREATE INDEX idx_mst_comp_treatment_01 ON mst_comp_treatment USING btree (facility_cd,is_del);