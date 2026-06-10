insert into ord_coop_no (
  facility_cd,
  pat_id,
  hosp_pat_id,
  ord_no,
  coop_cd,
  coop_ord_no,
  status,
  user_id,
-- add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  coop_version,
-- add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  reg_date,
  up_date
) values (
  /* ordCoopNo.facilityCd */null,
  /* ordCoopNo.patId */null,
  /* ordCoopNo.hospPatId */null,
  /* ordCoopNo.ordNo */null,
  /* ordCoopNo.coopCd */null,
  /* ordCoopNo.coopOrdNo */null,
  /* ordCoopNo.status */null,
  /* ordCoopNo.userId */null,
-- add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  /* ordCoopNo.coopVersion */'',
-- add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
)
