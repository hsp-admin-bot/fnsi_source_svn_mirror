﻿DROP INDEX IF EXISTS idx_mst_equipment_02;
CREATE INDEX idx_mst_equipment_02 ON mst_equipment USING btree (class_cd);
DROP INDEX IF EXISTS idx_mst_equipment_01;
CREATE INDEX idx_mst_equipment_01 ON mst_equipment USING btree (facility_cd);