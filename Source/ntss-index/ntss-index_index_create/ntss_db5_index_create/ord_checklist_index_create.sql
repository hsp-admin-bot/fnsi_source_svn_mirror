DROP INDEX IF EXISTS idx_ord_checklist_01;
CREATE INDEX idx_ord_checklist_01 ON ord_checklist USING btree (facility_cd,ord_no, list_cd, is_del);