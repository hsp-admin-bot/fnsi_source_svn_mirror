﻿DROP INDEX IF EXISTS idx_pat_group_02;
CREATE INDEX idx_pat_group_02 ON pat_group USING btree (is_del);
DROP INDEX IF EXISTS idx_pat_group_03;
CREATE INDEX idx_pat_group_03 ON pat_group USING btree (pat_group_cd,is_del);
DROP INDEX IF EXISTS idx_pat_group_01;
CREATE INDEX idx_pat_group_01 ON pat_group USING btree (facility_cd,is_del,is_disp);