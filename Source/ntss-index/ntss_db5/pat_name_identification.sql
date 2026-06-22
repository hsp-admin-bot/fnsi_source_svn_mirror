DROP INDEX IF EXISTS idx_pat_name_identification_01;
CREATE INDEX idx_pat_name_identification_01 ON pat_name_identification USING btree (facility_cd_src);