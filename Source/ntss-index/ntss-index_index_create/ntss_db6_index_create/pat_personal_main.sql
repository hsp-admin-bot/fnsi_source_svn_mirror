DROP INDEX IF EXISTS idx_pat_personal_main_02;
CREATE INDEX idx_pat_personal_main_02 ON pat_personal_main USING btree (facility_cd, hosp_pat_id, is_del);