-- 8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 周 add start
with temp_table as (select unnest(regexp_split_to_array(/*ctlNoList*/'', ',')::bigint[]) as tts)
-- 8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 周 add end
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
-- 8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 周 add start
from temp_table
-- 8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 周 add end
WHERE
  is_del = '0'
AND
-- 8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 周 mod start
--  ctl_no IN /*ctlNoList*/(0)
  ctl_no = temp_table.tts
-- 8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 周 mod end
;

