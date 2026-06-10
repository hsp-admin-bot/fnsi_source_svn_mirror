-- 水質検査種別マスタ.結果初期値 データ修正
-- 指数表記を通常表記に変換、小数部桁数を補填した値に変換
UPDATE mst_water_survey_type
SET initial_value = 
    CASE
        WHEN decimal_digits IS NOT NULL THEN
            -- 小数部桁数に基づいてフォーマット
            to_char((initial_value::numeric), 'FM999999990.' || repeat('0', decimal_digits))
        ELSE
            -- 小数部桁数が指定されていない場合、元の値を取得
            initial_value::numeric::text
    END,
    up_date = CURRENT_TIMESTAMP
WHERE initial_value ~ '^-?[0-9.]+([eE][+-]?[0-9]+)?$' -- 抽出対象：数値、指数表記、マイナス値含む
;
