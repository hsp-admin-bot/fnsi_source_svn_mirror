-- FUNCTION: json_array_contains_key_pair(jsonb, text, text, integer[], character varying)

DROP FUNCTION IF EXISTS json_array_contains_key_pair(jsonb, text, text, integer[], character varying);

CREATE OR REPLACE FUNCTION json_array_contains_key_pair(
	json_array jsonb,
	key1 text,
	key2 text,
	val1 integer[],
	val2 character varying)
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
  
  FOR i IN 0..(jsonb_array_length(json_array) - 1) LOOP
    IF ((json_array -> i ->> key1)::int = ANY(val1)) and ((json_array -> i ->> key2)::character varying = val2) THEN
      is_contained := true;
      EXIT;
    END IF;
  END LOOP;
  RETURN is_contained;
END;
$BODY$;
