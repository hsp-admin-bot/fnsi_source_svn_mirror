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
  pat_id = /* patId */'999999'
/*%end*/
AND
/*%if ordNo == null || ordNo == 0L */
-- mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
--  ord_no is null
  (ord_no is null OR ord_no = 0)
-- mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
/*%else*/
  ord_no = /* ordNo */'999999'
/*%end*/
AND
  coop_cd = /* coopCd */''
-- add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
AND coop_version = /* coopVersion */''
-- add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
AND
  is_del = '0'
