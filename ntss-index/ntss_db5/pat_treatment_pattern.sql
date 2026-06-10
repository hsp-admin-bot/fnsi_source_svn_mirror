DROP INDEX IF EXISTS idx_pat_treatment_pattern_01;
CREATE INDEX idx_pat_treatment_pattern_01 ON pat_treatment_pattern USING btree (facility_cd);