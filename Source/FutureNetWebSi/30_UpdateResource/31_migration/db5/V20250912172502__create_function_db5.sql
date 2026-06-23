CREATE OR REPLACE FUNCTION ntss.parse_csv_row(input text)
RETURNS TABLE(field text)
AS
$$
DECLARE
  pos int := 1;
  in_quotes boolean := false;
  buffer text := '';
  ch text;
BEGIN
  WHILE pos <= length(input) LOOP
    ch := substr(input, pos, 1);
    IF ch = '"' THEN
      IF in_quotes AND substr(input, pos+1, 1) = '"' THEN
        buffer := buffer || '"';
        pos := pos + 1;
      ELSE
        in_quotes := NOT in_quotes;
      END IF;
    ELSIF ch = ',' AND NOT in_quotes THEN
      field := buffer;
      RETURN NEXT;
      buffer := '';
    ELSE
      buffer := buffer || ch;
    END IF;
    pos := pos + 1;
  END LOOP;

  field := buffer;
  RETURN NEXT;
END
$$
 LANGUAGE plpgsql IMMUTABLE;


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
