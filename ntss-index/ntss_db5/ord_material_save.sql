﻿DROP INDEX IF EXISTS idx_ord_material_save_01;
CREATE INDEX idx_ord_material_save_01 ON ord_material_save USING btree (facility_cd,pat_id,supplies_base_date,supplies_source_class);
DROP INDEX IF EXISTS idx_ord_material_save_02;
CREATE INDEX idx_ord_material_save_02 ON ord_material_save USING btree (supplies_base_no);