DROP INDEX IF EXISTS idx_mst_equipment_class_01;
CREATE INDEX idx_mst_equipment_class_01 ON mst_equipment_class USING btree (facility_cd);