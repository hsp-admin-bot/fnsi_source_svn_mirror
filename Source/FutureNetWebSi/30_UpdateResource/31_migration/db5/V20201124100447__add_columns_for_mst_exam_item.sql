--検査項目マスタで透析前後指定用項目を追加する
ALTER TABLE ntss.mst_exam_item ADD dialysis_progress_flag varchar(2) NULL;
COMMENT ON COLUMN ntss.mst_exam_item.dialysis_progress_flag IS '透析工程フラグ';
