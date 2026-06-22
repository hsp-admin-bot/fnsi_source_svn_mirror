UPDATE
  ord_coop_no
SET
  is_del = '1',
  is_disp = '0',
  up_date = /*upDate*/null
WHERE
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
-- add by chamaojia 2023-05-16 [8637] クエリー条件を追加してインデックス効率を向上   --start
AND facility_cd = /* facilityCd */''
-- add by chamaojia 2023-05-16 [8637] クエリー条件を追加してインデックス効率を向上   --end
AND
  (is_del = '0' OR is_disp = '1')
/*%if coopOrdNo != null && !coopOrdNo.isEmpty() */
AND
  coop_ord_no = /*coopOrdNo*/null
/*%end*/

