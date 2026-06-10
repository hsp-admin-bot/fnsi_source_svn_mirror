-- 暗号化ファンクション登録(jsonb)
CREATE OR REPLACE FUNCTION personal_info_encrypt_jsonb(jsonb_data jsonb)
RETURNS jsonb AS
'
DECLARE
	encrypted_jsonb jsonb;
	result_jsonb jsonb;
BEGIN
	IF (jsonb_typeof(jsonb_data) = ''array'') THEN
		SELECT
			COALESCE(jsonb_agg(personal_info_encrypt_jsonb(value)), ''[]''::jsonb)
		INTO
			result_jsonb
		FROM
			jsonb_array_elements(jsonb_data) ;
	ELSIF (jsonb_typeof(jsonb_data) = ''object'') THEN
		-- エスケープ文字を挿入
		SELECT
			COALESCE(jsonb_object_agg(key, personal_info_encrypt(REPLACE(value::text, ''\'', ''\\''))), ''{}''::jsonb)
		INTO
			encrypted_jsonb
		FROM
			jsonb_each(jsonb_data)
		WHERE
			jsonb_typeof(value) = ''string'' ;

		SELECT
			jsonb_data || encrypted_jsonb
		INTO
			result_jsonb ;
	END IF ;
RETURN result_jsonb ;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE ''例外が発生しました。'' ;
		RETURN jsonb_data ;
END;
'
LANGUAGE 'plpgsql';