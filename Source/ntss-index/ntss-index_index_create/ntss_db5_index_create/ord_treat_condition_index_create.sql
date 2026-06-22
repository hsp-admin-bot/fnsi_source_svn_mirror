﻿DROP INDEX IF EXISTS idx_ord_treat_condition_03;
CREATE INDEX idx_ord_treat_condition_03 ON ord_treat_condition USING btree (ord_no,machine_no,treat_class,is_del);
DROP INDEX IF EXISTS idx_ord_treat_condition_01;
CREATE INDEX idx_ord_treat_condition_01 ON ord_treat_condition USING btree (facility_cd,ord_no);
DROP INDEX IF EXISTS idx_ord_treat_condition_02;
CREATE INDEX idx_ord_treat_condition_02 ON ord_treat_condition USING btree (facility_cd,receive_date,is_disp,is_del);