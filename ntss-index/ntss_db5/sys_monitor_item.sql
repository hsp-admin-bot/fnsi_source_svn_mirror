﻿DROP INDEX IF EXISTS idx_sys_monitor_item_01;
CREATE INDEX idx_sys_monitor_item_01 ON sys_monitor_item USING btree (moni_data_type,vital_monitor_class,moni_data_no);
DROP INDEX IF EXISTS idx_sys_monitor_item_02;
CREATE INDEX idx_sys_monitor_item_02 ON sys_monitor_item USING btree (moni_data_type,vital_monitor_class);