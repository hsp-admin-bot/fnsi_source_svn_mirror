DROP INDEX IF EXISTS idx_pat_ind_approve_01;
CREATE INDEX idx_pat_ind_approve_01 ON pat_ind_approve USING btree (facility_cd,check_user1_cd,approve_user1_cd);