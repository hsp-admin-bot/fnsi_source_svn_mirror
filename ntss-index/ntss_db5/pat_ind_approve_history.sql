DROP INDEX IF EXISTS idx_pat_ind_approve_history_01;
CREATE INDEX idx_pat_ind_approve_history_01 ON pat_ind_approve_history USING btree (ord_no,approve_kind);