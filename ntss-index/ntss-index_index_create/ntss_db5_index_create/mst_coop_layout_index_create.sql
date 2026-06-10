﻿DROP INDEX IF EXISTS idx_mst_coop_layout_01;
CREATE INDEX idx_mst_coop_layout_01 ON mst_coop_layout USING btree (facility_cd,coop_cd,coop_cd_index,direction,coop_cd_sub,is_del);
DROP INDEX IF EXISTS idx_mst_coop_layout_02;
CREATE INDEX idx_mst_coop_layout_02 ON mst_coop_layout USING btree (facility_cd,is_del,is_disp);
DROP INDEX IF EXISTS idx_mst_coop_layout_03;
CREATE INDEX idx_mst_coop_layout_03 ON mst_coop_layout USING btree (facility_cd,is_del,coop_name,is_disp);