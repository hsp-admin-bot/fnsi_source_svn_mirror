-- インデックス削除（標準医薬品マスタ）
DROP INDEX IF EXISTS idx_sys_medicine_01;

-- インデックス追加（標準医薬品マスタ）
CREATE INDEX idx_sys_medicine_01 ON sys_medicine (standard_medicine_cd);
