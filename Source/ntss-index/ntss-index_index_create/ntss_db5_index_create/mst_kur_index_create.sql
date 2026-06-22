﻿DROP INDEX IF EXISTS idx_mst_kur_01;
CREATE INDEX idx_mst_kur_01 ON mst_kur USING btree (facility_cd,kur_cd);
DROP INDEX IF EXISTS idx_mst_kur_02;
CREATE INDEX idx_mst_kur_02 ON mst_kur USING btree (is_del);