DROP INDEX IF EXISTS idx_mst_procedure_01;
CREATE INDEX idx_mst_procedure_01 ON mst_procedure USING btree (facility_cd);