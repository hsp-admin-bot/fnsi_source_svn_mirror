﻿DROP INDEX IF EXISTS idx_mst_machine_02;
CREATE INDEX idx_mst_machine_02 ON mst_machine USING btree (is_disp,machine_type_cd);
DROP INDEX IF EXISTS idx_mst_machine_01;
CREATE INDEX idx_mst_machine_01 ON mst_machine USING btree (facility_cd,machine_no,is_del);