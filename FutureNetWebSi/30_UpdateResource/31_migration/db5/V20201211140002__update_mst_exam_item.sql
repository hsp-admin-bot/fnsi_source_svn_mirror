-- 正常値(上限) 正常値(下限) 正常値(男性上限) 正常値(男性下限) 正常値(女性上限) 正常値(女性下限) 入力上限値 入力下限値 グラフ上限値 グラフ下限値  データタイプの変更
ALTER TABLE ntss.mst_exam_item ALTER COLUMN normal_value_upper TYPE varchar USING normal_value_upper::varchar;
ALTER TABLE ntss.mst_exam_item ALTER COLUMN normal_value_lower TYPE varchar USING normal_value_lower::varchar;
ALTER TABLE ntss.mst_exam_item ALTER COLUMN normal_value_upper_m TYPE varchar USING normal_value_upper_m::varchar;
ALTER TABLE ntss.mst_exam_item ALTER COLUMN normal_value_lower_m TYPE varchar USING normal_value_lower_m::varchar;
ALTER TABLE ntss.mst_exam_item ALTER COLUMN normal_value_upper_w TYPE varchar USING normal_value_upper_w::varchar;
ALTER TABLE ntss.mst_exam_item ALTER COLUMN normal_value_lower_w TYPE varchar USING normal_value_lower_w::varchar;
ALTER TABLE ntss.mst_exam_item ALTER COLUMN input_upper TYPE varchar USING input_upper::varchar;
ALTER TABLE ntss.mst_exam_item ALTER COLUMN input_lower TYPE varchar USING input_lower::varchar;
ALTER TABLE ntss.mst_exam_item ALTER COLUMN graph_upper TYPE varchar USING graph_upper::varchar;
ALTER TABLE ntss.mst_exam_item ALTER COLUMN graph_lower TYPE varchar USING graph_lower::varchar;