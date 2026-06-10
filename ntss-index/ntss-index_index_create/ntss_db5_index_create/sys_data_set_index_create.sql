﻿DROP INDEX IF EXISTS idx_sys_data_set_02;
CREATE INDEX idx_sys_data_set_02 ON sys_data_set USING btree (use_application);
DROP INDEX IF EXISTS idx_sys_data_set_use_application_01;
CREATE INDEX idx_sys_data_set_use_application_01 ON sys_data_set USING GIN ((use_application -> 'applications'));