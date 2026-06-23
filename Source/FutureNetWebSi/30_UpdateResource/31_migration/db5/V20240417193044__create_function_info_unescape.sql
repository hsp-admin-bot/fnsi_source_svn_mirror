-- 渡されたinDataに含まれるエスケープをもとに戻す
-- @param {text} inData
-- @returns {text}
CREATE OR REPLACE FUNCTION info_unescape(inData text)
RETURNS TEXT
AS '
DECLARE
	str1 TEXT;
	str2 TEXT;
	str3 TEXT;
	replaceData TEXT;
BEGIN
	IF inData IS NOT NULL THEN
		str1 := REPLACE(inData, ''\"'', ''"'');
		str2 := REPLACE(str1, ''\\'', ''\'');
		str3 := REPLACE(str2, ''\n'', chr(10));
		replaceData := REPLACE(str3, ''\t'', chr(9));
	END IF;
RETURN replaceData;
END;
'
LANGUAGE 'plpgsql';
