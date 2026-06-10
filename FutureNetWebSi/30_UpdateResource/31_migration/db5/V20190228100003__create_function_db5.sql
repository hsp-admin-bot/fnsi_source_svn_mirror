-- ord_main.ind_cond_infoから指定した治療条件項目番号の値を取得
-- @param {jsonb} ind_cond_info
-- @param {text} cond_id 治療条件項目番号
-- @returns {int}
CREATE OR REPLACE FUNCTION ind_cond_info_value(ind_cond_info jsonb, cond_id text)
RETURNS text
AS '
DECLARE
BEGIN
  RETURN ind_cond_info -> cond_id ->> ''value'';
END;
'
LANGUAGE 'plpgsql';

-- JSON配列に指定したキーの値が配列要素に存在するか判定
-- @param {jsonb} json_array JSON配列
-- @param {text} key JSONキー
-- @param {int[]} ary 配列要素
-- @returns {boolean}
CREATE OR REPLACE FUNCTION json_array_contains_array_value(json_array jsonb, key text, ary int[])
RETURNS boolean
AS '
DECLARE
  is_contained boolean := false;
BEGIN
  -- JSON配列の要素をループ
  FOR i IN 0..(jsonb_array_length(json_array) - 1) LOOP
    IF ((json_array -> i ->> key)::int = ANY(ary)) THEN
      -- 値を含む
      is_contained := true;
      EXIT;
    END IF;
  END LOOP;
  RETURN is_contained;
END;
'
LANGUAGE 'plpgsql';

-- 指定したキーの値と一致する要素がJSON配列に存在するか判定
-- @param {jsonb} json_array JSON配列
-- @param {text} key JSONキー
-- @param {text} value 判定する値
-- @param {boolean} partial_match valueの比較方式 (true: 部分一致, false: 完全一致)
-- @returns {boolean}
CREATE OR REPLACE FUNCTION json_array_contains_value(json_array jsonb, key text, value text, partial_match boolean)
RETURNS boolean
AS '
DECLARE
  is_contained boolean := false;
BEGIN
  -- JSON配列の要素をループ
  FOR i IN 0..(jsonb_array_length(json_array) - 1) LOOP
    IF (partial_match and json_array -> i ->> key like ''%'' || value || ''%'') or
       (not partial_match and json_array -> i ->> key = value) THEN
      -- 値が部分一致または完全一致
      is_contained := true;
      EXIT;
    END IF;
  END LOOP;
  RETURN is_contained;
END;
'
LANGUAGE 'plpgsql';

-- 指定したキーの値と分類キーの値が一致する要素がJSON配列に存在するか判定
-- @param {jsonb} json_array JSON配列
-- @param {text} key JSONキー
-- @param {text} value 指定したJSONキーの値
-- @param {text} class_key 分類JSONキー
-- @param {text} class_value 指定した分類JSONキーの値
-- @param {boolean} partial_match valueの比較方式 (true: 部分一致, false: 完全一致)
-- @returns {boolean}
CREATE OR REPLACE FUNCTION json_array_contains_value_with_class(json_array jsonb, key text, value text, class_key text, class_value text, partial_match boolean)
RETURNS boolean
AS '
DECLARE
  is_contained boolean := false;
BEGIN
  -- JSON配列の要素をループ
  FOR i IN 0..(jsonb_array_length(json_array) - 1) LOOP
    IF ((partial_match and json_array -> i ->> key like ''%'' || value || ''%'') or
       (not partial_match and json_array -> i ->> key = value)) and
       (json_array -> i ->> class_key = class_value) THEN
      -- 値が部分一致または完全一致し、かつ分類キーも一致
      is_contained := true;
      EXIT;
    END IF;
  END LOOP;
  RETURN is_contained;
END;
'
LANGUAGE 'plpgsql';
