-- 一意のキー制約を作成、削除します。
alter table sys_daily_no drop constraint if EXISTS unq_sys_daily_no_02;
ALTER TABLE sys_daily_no ADD CONSTRAINT unq_sys_daily_no_02 UNIQUE (facility_cd, numbering_cd, is_del);
