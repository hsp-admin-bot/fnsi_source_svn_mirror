DROP INDEX IF EXISTS idx_mst_water_survey_point_01;
CREATE INDEX idx_mst_water_survey_point_01 ON mst_water_survey_point USING btree (survey_type_cd,is_del);