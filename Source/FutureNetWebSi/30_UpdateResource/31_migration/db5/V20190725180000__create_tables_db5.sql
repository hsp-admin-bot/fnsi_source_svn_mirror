-- 指定したキーの値と一致する要素がJSON配列に存在するか判定
-- @param {jsonb} json_array JSON配列
-- @param {text} key JSONキー
-- @param {text} value 判定する値
-- @param {text} match_method 比較方式 ('1': 完全一致, '2': 部分一致, '3': 前方一致)
-- @returns {boolean}
CREATE OR REPLACE FUNCTION json_array_contains_value(json_array jsonb, key text, value text, match_method text)
RETURNS boolean
AS '
DECLARE
  is_contained boolean := false;
  match_string text;
BEGIN
  IF json_array is null THEN
    RETURN false;
  END IF;
  
  -- 比較文字列の作成
  IF match_method = ''1'' THEN
    -- 完全一致
    match_string := value;
  ELSIF match_method = ''2'' THEN
    -- 部分一致
    match_string := ''%'' || value || ''%'';
  ELSE
    -- 前方一致
    match_string := value || ''%'';
  END IF;
  
  -- JSON配列の要素をループ
  FOR i IN 0..(jsonb_array_length(json_array) - 1) LOOP
    IF (json_array -> i ->> key) like match_string THEN
      is_contained := true;
      EXIT;
    END IF;
  END LOOP;
  RETURN is_contained;
END;
'
LANGUAGE 'plpgsql';