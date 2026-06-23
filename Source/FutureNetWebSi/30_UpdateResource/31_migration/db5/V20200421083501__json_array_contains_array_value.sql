
DROP FUNCTION IF EXISTS json_array_contains_array_value(jsonb, text, character varying);

CREATE OR REPLACE FUNCTION json_array_contains_array_value(
	json_array jsonb,
	key text,
	ary character varying)
    RETURNS boolean
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$DECLARE
  is_contained boolean := false;
BEGIN
  IF json_array IS NULL THEN
    RETURN is_contained;
  END IF;
  
  -- JSON配列の要素をループ
  FOR i IN 0..(jsonb_array_length(json_array) - 1) LOOP
    IF ((json_array -> i ->> key)::character varying = ary) THEN
      -- 値を含む
      is_contained := true;
      EXIT;
    END IF;
  END LOOP;
  RETURN is_contained;
END;
$BODY$;
