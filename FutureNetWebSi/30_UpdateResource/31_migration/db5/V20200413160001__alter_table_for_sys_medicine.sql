-- 既存のプライマリキーの削除
ALTER TABLE sys_medicine DROP CONSTRAINT unq_sys_medicine_01;

-- プライマリキーの追加
ALTER TABLE sys_medicine ADD CONSTRAINT unq_sys_medicine_01 PRIMARY KEY(standard_no);

-- JANコードのnot null制約を解除
ALTER TABLE sys_medicine ALTER COLUMN jan_cd DROP NOT NULL;
