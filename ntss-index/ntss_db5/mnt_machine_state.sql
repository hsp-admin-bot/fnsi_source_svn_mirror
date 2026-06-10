﻿DROP INDEX IF EXISTS idx_mnt_machine_state_01;
CREATE INDEX idx_mnt_machine_state_01 ON mnt_machine_state USING btree (facility_cd,bed_cd);
DROP INDEX IF EXISTS idx_mnt_machine_state_02;
CREATE INDEX idx_mnt_machine_state_02 ON mnt_machine_state USING btree (facility_cd,TRIM(machine_serial));
DROP INDEX IF EXISTS idx_mnt_machine_state_03;
CREATE INDEX idx_mnt_machine_state_03 ON mnt_machine_state USING btree (machine_type_cd,machine_serial);