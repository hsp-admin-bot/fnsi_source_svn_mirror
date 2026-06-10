﻿DROP INDEX IF EXISTS idx_sys_coop_journal_01;
CREATE INDEX idx_sys_coop_journal_01 ON sys_coop_journal USING btree (facility_cd,coop_cd,coop_cd_index,crud,direction,is_del);
DROP INDEX IF EXISTS idx_sys_coop_journal_02;
CREATE INDEX idx_sys_coop_journal_02 ON sys_coop_journal USING btree (facility_cd, pat_id);