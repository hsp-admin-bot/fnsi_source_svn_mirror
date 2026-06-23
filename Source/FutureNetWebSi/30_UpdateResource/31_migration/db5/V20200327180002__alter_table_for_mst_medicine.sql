-- 指示単位小数部桁数・レセ単位小数部桁数にデフォルト値を設定
ALTER TABLE mst_medicine ALTER COLUMN unit_decimal_point SET DEFAULT 0;
ALTER TABLE mst_medicine ALTER COLUMN unit_decimal_point_second SET DEFAULT 0;
