﻿DROP INDEX IF EXISTS idx_mst_medicine_02;
CREATE INDEX idx_mst_medicine_02 ON mst_medicine USING btree (facility_cd,class_cd);
DROP INDEX IF EXISTS idx_mst_medicine_01;
CREATE INDEX idx_mst_medicine_01 ON mst_medicine USING btree (facility_cd);