UPDATE
  sys_coop_journal
SET
  temp_content = CASE
    WHEN temp_content is null THEN
      ('[' || /* tempContent */null || ']') :: jsonb
    ELSE
      temp_content || ('[' || /* tempContent */null || ']') :: jsonb
    END
  ,crud = /* crud */''
  ,up_date = /* now */'2019-11-10 11:00:00'
WHERE
  ctl_no = /* ctlNo */'999999'
