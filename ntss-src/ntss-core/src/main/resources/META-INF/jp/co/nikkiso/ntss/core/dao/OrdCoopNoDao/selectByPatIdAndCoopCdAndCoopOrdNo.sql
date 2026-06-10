SELECT
  /*%expand*/*
FROM
  ord_coop_no
WHERE
  facility_cd = /*facilityCd*/'1'
AND
/*%if patId == null || patId == 0L */
  hosp_pat_id = /* hospPatId */'0'
/*%else*/
  pat_id = /* patId */'000000'
/*%end*/
AND
  coop_cd = /* coopCd */'000000'
-- add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
AND coop_version = /* coopVersion */''
-- add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
AND
  coop_ord_no = /* coopOrdNo */'000000'
AND is_del = '0'
;
