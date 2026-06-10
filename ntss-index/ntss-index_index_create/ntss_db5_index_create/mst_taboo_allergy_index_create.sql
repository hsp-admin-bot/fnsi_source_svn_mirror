DROP INDEX IF EXISTS idx_mst_taboo_allergy_01;
CREATE INDEX idx_mst_taboo_allergy_01 ON mst_taboo_allergy USING btree (facility_cd);