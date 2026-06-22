﻿DROP INDEX IF EXISTS idx_mst_dialyzer_01;
CREATE INDEX idx_mst_dialyzer_01 ON mst_dialyzer USING btree (facility_cd,is_disp,is_del);
DROP INDEX IF EXISTS idx_mst_dialyzer_02;
CREATE INDEX idx_mst_dialyzer_02 ON mst_dialyzer USING btree (in_hospital_cd_1);