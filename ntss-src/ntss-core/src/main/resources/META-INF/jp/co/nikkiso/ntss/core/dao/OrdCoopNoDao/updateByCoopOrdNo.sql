UPDATE
  ord_coop_no
SET
  pat_id = /* ordCoopNo.patId */null,
  hosp_pat_id = /* ordCoopNo.hospPatId */null,
  ord_no = /* ordCoopNo.ordNo */null,
  status = /* ordCoopNo.status */null,
  user_id = /* ordCoopNo.userId */null,
  up_date = CURRENT_TIMESTAMP(3)
WHERE
  facility_cd = /* ordCoopNo.facilityCd */'000000'
and
/*%if ordCoopNo.patId == null || ordCoopNo.patId == 0L */
  hosp_pat_id = /* ordCoopNo.hospPatId */null
/*%else*/
  pat_id = /* ordCoopNo.patId */null
/*%end*/
and
  coop_cd = /* ordCoopNo.coopCd */null
-- add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
AND coop_version = /* ordCoopNo.coopVersion */''
-- add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
and
  coop_cd_index = /* ordCoopNo.coopCdIndex */null
and
  coop_ord_no = /* ordCoopNo.coopOrdNo */null
