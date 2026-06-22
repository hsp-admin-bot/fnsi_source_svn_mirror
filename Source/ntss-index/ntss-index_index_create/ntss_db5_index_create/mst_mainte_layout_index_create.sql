DROP INDEX IF EXISTS idx_mst_mainte_layout_01;
CREATE INDEX idx_mst_mainte_layout_01 ON mst_mainte_layout USING btree (layout_class,is_del,is_disp);