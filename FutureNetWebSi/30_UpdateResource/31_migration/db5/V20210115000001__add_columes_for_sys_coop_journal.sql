ALTER TABLE ntss.sys_coop_journal ADD retry_cnt character varying(1) default '0';

COMMENT ON COLUMN ntss.sys_coop_journal.retry_cnt IS '表示フラグ';
