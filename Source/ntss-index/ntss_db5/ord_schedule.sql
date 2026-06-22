﻿DROP INDEX IF EXISTS idx_ord_schedule_02;
CREATE INDEX idx_ord_schedule_02 ON ord_schedule USING btree (ord_no,treat_date);
DROP INDEX IF EXISTS idx_ord_schedule_01;
CREATE INDEX idx_ord_schedule_01 ON ord_schedule USING btree (facility_cd,treat_date,kur_cd,bed_cd);