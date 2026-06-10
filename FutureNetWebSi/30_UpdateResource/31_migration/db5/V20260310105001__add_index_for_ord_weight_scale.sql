-- #12544：体重計測定記録画面の表示が遅い
-- 体重計測定記録画面の表示にてディスク読込による遅延が発生していた為、クエリに対応したインデックス追加を行う。
-- 対象クエリ：\OrdWeightScaleDao\selectByFacility.sql

-- ord_weight_scale（体重計測定記録）
-- インデックス削除
DROP INDEX IF EXISTS idx_ord_weight_scale_03;
-- インデックス追加
CREATE INDEX idx_ord_weight_scale_03 ON ntss.ord_weight_scale (
  facility_cd,
  measure_date
);
