-- add 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫
SELECT
  /*%expand*/*
FROM
  mst_coop_layout_detail
WHERE
  facility_cd = /* facilityCd */'999999'
AND
  coop_cd = /* coopCd */''
AND
  coop_version = /* coopVersion */''
AND
  direction = /* direction */''
AND
  coop_cd_detail = /* coopCdDetail */''
AND
  coop_cd_detail_sub = /* coopCdDetailSub */''
AND
  is_del = '0'
