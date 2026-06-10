UPDATE
  ord_coop_no
SET
  status = '1',
  up_date = /*upDate*/null
WHERE
  facility_cd = /*facilityCd*/'000000'
and
/*%if patId == null || patId == 0L */
  hosp_pat_id = /* hospPatId */null
/*%else*/
  pat_id = /*patId*/null
/*%end*/
and
/*%if ordNo == null || ordNo == 0L */
-- mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
--  ord_no is null
  (ord_no is null OR ord_no = 0)
-- mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
/*%else*/
  ord_no = /*ordNo*/null
/*%end*/
and
  coop_cd = /*coopCd*/null
-- add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
AND coop_version = /* coopVersion */''
-- add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
and
  coop_ord_no = /*coopOrdNo*/null
and
  status = '0'
and
  is_del = '0' 
and 
  is_disp = '1'
