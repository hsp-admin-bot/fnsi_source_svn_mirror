DROP INDEX IF EXISTS sys_coop_journal_idx_02;
CREATE INDEX sys_coop_journal_idx_02
ON sys_coop_journal (
    facility_cd,
    ana_result,
    direction,
    coop_result,
    is_del,
    ctl_no
);
