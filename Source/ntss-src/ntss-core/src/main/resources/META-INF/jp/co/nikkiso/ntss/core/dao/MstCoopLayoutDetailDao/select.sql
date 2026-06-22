SELECT
  /*%expand*/*
FROM
  mst_coop_layout_detail
WHERE
  facility_cd = /* facilityCd */'999999'
AND
  coop_cd = /* coopCd */''
-- add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
AND coop_version = /* coopVersion */''
-- add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
AND
  direction = /* direction */''
AND
  coop_cd_detail = /* coopCdDetail */''
AND
  coop_cd_detail_sub = /* coopCdDetailSub */''
AND
  is_del = '0'
