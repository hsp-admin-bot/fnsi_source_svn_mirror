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