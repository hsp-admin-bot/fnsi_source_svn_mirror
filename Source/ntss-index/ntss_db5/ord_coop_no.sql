﻿DROP INDEX IF EXISTS idx_ord_coop_no_01;
CREATE INDEX idx_ord_coop_no_01 ON ord_coop_no USING btree (facility_cd,ord_no,coop_cd);
DROP INDEX IF EXISTS idx_ord_coop_no_02;
CREATE INDEX idx_ord_coop_no_02 ON ord_coop_no USING btree (facility_cd,pat_id,coop_cd,coop_ord_no,is_del);
DROP INDEX IF EXISTS idx_ord_coop_no_03;
CREATE INDEX idx_ord_coop_no_03 ON ord_coop_no USING btree (facility_cd,hosp_pat_id,coop_ord_no);