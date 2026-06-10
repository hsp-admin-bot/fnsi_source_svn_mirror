﻿DROP INDEX IF EXISTS idx_mst_treatment_01;
CREATE INDEX idx_mst_treatment_01 ON mst_treatment USING btree (facility_cd,treatment_cd,is_del);
DROP INDEX IF EXISTS idx_mst_treatment_02;
CREATE INDEX idx_mst_treatment_02 ON mst_treatment USING btree (facility_cd);