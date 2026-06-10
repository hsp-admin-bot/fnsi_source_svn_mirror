﻿DROP INDEX IF EXISTS idx_mst_course_01;
CREATE INDEX idx_mst_course_01 ON mst_course USING btree (is_del,is_disp);
DROP INDEX IF EXISTS idx_mst_course_02;
CREATE INDEX idx_mst_course_02 ON mst_course USING btree (facility_cd);