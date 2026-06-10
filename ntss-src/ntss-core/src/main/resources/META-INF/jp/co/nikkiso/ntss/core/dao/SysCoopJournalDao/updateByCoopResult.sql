--#8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230406 mod start
WITH temp_table AS (SELECT unnest(regexp_split_to_array(/*ctlNoList*/'', ',')::bigint[]) AS tts)
--#8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230406 mod end
UPDATE
  sys_coop_journal
SET
  coop_result = /* coopResult */'1'
/*%if coopResult == "1" */
  ,in_reg_date = /* now */'2019-11-10 11:00:00'
/*%end*/
  , up_date = /* now */null
--#8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230406 mod start
FROM temp_table
--#8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230406 mod end
WHERE
--#8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230406 mod start
  --ctl_no in /* ctlNoList */(0)
  ctl_no = temp_table.tts
-- add by chamaojia 2024-09-26 [10574] add modification conditions, only 0 and R can become 1 --start
/*%if coopResult == "1" */
  and coop_result in ('0', 'R')
/*%end*/
-- add by chamaojia 2024-09-26 [10574] add modification conditions, only 0 and R can become 1 --end
--#8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230406 mod end
;
