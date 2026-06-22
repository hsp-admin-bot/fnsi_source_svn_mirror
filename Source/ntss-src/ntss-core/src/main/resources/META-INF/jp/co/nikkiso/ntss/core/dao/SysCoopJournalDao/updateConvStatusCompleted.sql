--#8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230406 mod start
WITH temp_table AS (SELECT unnest(regexp_split_to_array(/*ctlNoList*/'', ',')::bigint[]) AS tts)
--#8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230406 mod end
UPDATE
  sys_coop_journal
SET
  ana_result = /* statusCode */'',
  out_ana_date = /* now */'',
  up_date = /* now */''
--#8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230406 mod start
FROM temp_table
--#8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230406 mod end
WHERE
  is_del = '0'
AND
--#8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230406 mod start
  --ctl_no IN /*ctlNoList*/(0)
  ctl_no = temp_table.tts
--#8229-外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230406 mod end
;
