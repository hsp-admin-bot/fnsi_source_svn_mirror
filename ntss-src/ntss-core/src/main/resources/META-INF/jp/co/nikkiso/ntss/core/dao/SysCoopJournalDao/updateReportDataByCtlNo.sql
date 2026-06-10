UPDATE
  sys_coop_journal
SET
  up_date = now()
  , report_cd = /* reportCd */''
  , dump_path = /* dumpPath */''
WHERE
  ctl_no = /* ctlNo */'999999'