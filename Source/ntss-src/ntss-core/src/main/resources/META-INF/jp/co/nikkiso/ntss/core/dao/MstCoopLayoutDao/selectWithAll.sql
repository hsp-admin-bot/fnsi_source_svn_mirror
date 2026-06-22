SELECT
  /*%expand*/*
FROM
  mst_coop_layout
WHERE
  facility_cd = /* facilityCd */'999999'
AND
  coop_cd = /* coopCd */''
AND
  coop_cd_index = /* coopCdIndex */''
-- add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
AND coop_version = /* coopVersion */''
-- add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
AND
  direction = /* direction */''
AND
  coop_cd_sub IN (/* coopCdSub */'', /* allConst */'all')
AND
  is_del = '0'
ORDER BY
CASE WHEN coop_cd_sub = /* allConst */'all' THEN -1
     ELSE -2
END
DESC
-- del 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
--LIMIT 1
-- del 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end
;
