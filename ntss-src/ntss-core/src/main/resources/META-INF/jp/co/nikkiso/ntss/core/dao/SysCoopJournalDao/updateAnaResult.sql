UPDATE
  sys_coop_journal
SET
  ana_result = /* anaResult */'1'
/*%if anaResult == "1" */
  ,in_ana_date = /* now */'2019-11-10 11:00:00'
/*%end*/

  ,out_ana_date = /* now */'2019-11-10 11:00:00'

  ,up_date = /* now */'2019-11-10 11:00:00'
/*%if message != null */
  ,message = /* message */''
/*%end*/
WHERE
  ctl_no = /* ctlNo */'999999'