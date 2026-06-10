--検査項目マスタ   計算式領域free_calc   上限の削除
ALTER TABLE ntss.mst_exam_item ALTER COLUMN free_calc TYPE varchar USING free_calc::varchar;