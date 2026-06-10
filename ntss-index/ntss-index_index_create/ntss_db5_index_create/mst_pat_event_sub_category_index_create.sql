﻿DROP INDEX IF EXISTS idx_mst_pat_event_sub_category_01;
CREATE INDEX idx_mst_pat_event_sub_category_01 ON mst_pat_event_sub_category USING btree (facility_cd);
DROP INDEX IF EXISTS idx_mst_pat_event_sub_category_02;
CREATE INDEX idx_mst_pat_event_sub_category_02 ON mst_pat_event_sub_category USING btree (category_cd,is_disp,is_del);