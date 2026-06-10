DROP INDEX IF EXISTS idx_mst_implant_01;
CREATE INDEX idx_mst_implant_01 ON mst_implant USING btree (facility_cd);