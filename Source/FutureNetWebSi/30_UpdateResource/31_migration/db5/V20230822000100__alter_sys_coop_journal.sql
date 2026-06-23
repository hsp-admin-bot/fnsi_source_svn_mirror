alter table sys_coop_journal  drop column retry_cnt;
alter table sys_coop_journal add column retry_cnt INTEGER DEFAULT 0 not null;
