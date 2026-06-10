-- 指定したキーの値と一致する要素(自施設登録)がpat_uniqueのJSON配列に存在するか判定
-- @param {jsonb} json_array JSON配列
-- @param {text} key JSONキー
-- @param {text} value 判定する値
-- @param {text[]} facility_cd_ary 施設コード
-- @returns {boolean}
CREATE OR REPLACE FUNCTION pat_unique_json_contains_value(json_array jsonb, key text, value text, facility_cd_ary text[])
RETURNS boolean
AS '
DECLARE
  is_contained boolean := false;
BEGIN
  -- JSON配列の要素をループ
  FOR i IN 0..(jsonb_array_length(json_array) - 1) LOOP
    IF ((json_array -> i ->> key) = value and (json_array -> i ->> ''facility_cd'') = ANY(facility_cd_ary)) THEN
      is_contained := true;
      EXIT;
    END IF;
  END LOOP;
  RETURN is_contained;
END;
'
LANGUAGE 'plpgsql';
