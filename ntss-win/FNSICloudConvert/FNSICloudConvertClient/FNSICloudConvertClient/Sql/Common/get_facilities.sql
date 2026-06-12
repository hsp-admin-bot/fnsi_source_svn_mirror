-- 施設マスタ一覧を取得する (クラウド→オンプレ 用: ntss.mst_facility を直接参照)
SELECT
    facility_cd,
    facility_name
FROM
    ntss.mst_facility
ORDER BY
    facility_cd
