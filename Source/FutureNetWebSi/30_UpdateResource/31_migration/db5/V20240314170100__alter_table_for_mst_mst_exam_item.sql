--データ形式 '1'：数値
ALTER TABLE mst_exam_item ALTER COLUMN data_type SET DEFAULT '1';

--仮想端末表示対象区分 '0'：対象外
ALTER TABLE mst_exam_item ALTER COLUMN console_class SET DEFAULT '0';
