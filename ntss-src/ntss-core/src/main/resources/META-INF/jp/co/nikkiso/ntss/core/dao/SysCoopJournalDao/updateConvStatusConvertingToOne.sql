UPDATE
  sys_coop_journal
SET
  ana_result = /* statusCode */'',
  in_ana_date = /* now */'',
/*%if statusCode == "1" */
  message = null,
  temp_content = null,
/*%end*/
  up_date = /* now */''
WHERE
  is_del = '0'
AND
  ctl_no = /* ctlNo */0
AND
  ana_result = /* beforeStatusCode */''
;

