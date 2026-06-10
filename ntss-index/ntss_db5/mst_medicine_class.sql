DROP INDEX IF EXISTS idx_mst_medicine_class_01;
CREATE INDEX idx_mst_medicine_class_01 ON mst_medicine_class USING btree (facility_cd,class_type,is_disp,is_del);