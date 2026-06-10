UPDATE
  sys_coop_journal
SET
  crud = /* crud */''
  ,coop_ord_no = /* coopOrdNo */null
  ,ana_result = /* anaResult */'1'
/*%if anaResult == "1" */
  , in_ana_date = /* now */'2019-11-10 11:00:00'
/*%end*/
/*%if anaResult == "9" */
  , out_ana_date = /* now */'2019-11-10 11:00:00'
/*%end*/
  , up_date = /* now */'2019-11-10 11:00:00'
  , dump_path = /* dumpPath */''
  , dump = /* dump */''
WHERE
  ctl_no = /* ctlNo */'999999'