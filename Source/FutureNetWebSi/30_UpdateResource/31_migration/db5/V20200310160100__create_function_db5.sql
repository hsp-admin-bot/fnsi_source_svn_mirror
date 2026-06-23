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
  IF json_array ISNULL THEN
   RETURN is_contained;
  END IF;
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
