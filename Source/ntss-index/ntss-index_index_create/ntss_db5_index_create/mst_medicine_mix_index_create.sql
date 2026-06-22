DROP INDEX IF EXISTS idx_mst_medicine_mix_01;
CREATE INDEX idx_mst_medicine_mix_01 ON mst_medicine_mix USING btree (facility_cd);