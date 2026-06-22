CREATE OR REPLACE FUNCTION ntss.extract_csv_records(csv_text text)
RETURNS TABLE(record text)
AS
$$
DECLARE
  ch text;
  in_quotes boolean := false;
  buffer text := '';
  i integer := 1;
  len integer := length(csv_text);
BEGIN
  WHILE i <= len LOOP
    ch := substr(csv_text, i, 1);
    buffer := buffer || ch;

    IF ch = '"' THEN
      IF substr(csv_text, i+1, 1) = '"' THEN
        buffer := buffer || '"';
        i := i + 1;
      ELSE
        in_quotes := NOT in_quotes;
      END IF;
    ELSIF ch = E'\n' AND NOT in_quotes THEN
      record := rtrim(buffer, E'\n\r');
      RETURN NEXT;
      buffer := '';
    END IF;

    i := i + 1;
  END LOOP;

  IF buffer <> '' THEN
    record := rtrim(buffer, E'\n\r');
    RETURN NEXT;
  END IF;
END
$$
 LANGUAGE plpgsql IMMUTABLE;
