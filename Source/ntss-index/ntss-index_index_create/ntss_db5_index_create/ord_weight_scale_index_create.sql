DROP INDEX IF EXISTS idx_ord_weight_scale_01;
CREATE INDEX idx_ord_weight_scale_01 ON ord_weight_scale USING btree (facility_cd,measure_date);