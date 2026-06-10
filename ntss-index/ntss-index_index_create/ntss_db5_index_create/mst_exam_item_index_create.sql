DROP INDEX IF EXISTS idx_mst_exam_item_02;
CREATE INDEX idx_mst_exam_item_02 ON mst_exam_item USING btree (facility_cd,exam_class,is_disp);