DROP INDEX IF EXISTS idx_pat_group_detail_01;
CREATE INDEX idx_pat_group_detail_01 ON pat_group_detail USING btree (pat_id);