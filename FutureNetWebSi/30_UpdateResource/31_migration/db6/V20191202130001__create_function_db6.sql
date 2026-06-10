-- 復号化ファンクション登録(jsonb)
CREATE OR REPLACE FUNCTION personal_info_decrypt_jsonb(jsonb_data jsonb)
RETURNS jsonb AS
'
DECLARE
	decrypted_jsonb jsonb;
	result_jsonb jsonb;
BEGIN
	IF (jsonb_typeof(jsonb_data) = ''array'') THEN
		SELECT
			COALESCE(jsonb_agg(personal_info_decrypt_jsonb(value)), ''[]''::jsonb)
		INTO
			result_jsonb
		FROM
			jsonb_array_elements(jsonb_data) ;
	ELSIF (jsonb_typeof(jsonb_data) = ''object'') THEN
		-- "ccdede" → ccdede のように変換し、jsonbに型キャストしてエスケープ文字を除く
		SELECT
			COALESCE(jsonb_object_agg(key, personal_info_decrypt(REPLACE(value::text, ''"'', ''''))::jsonb), ''{}''::jsonb)
		INTO
			decrypted_jsonb
		FROM
			jsonb_each(jsonb_data)
		WHERE
			jsonb_typeof(value) = ''string'' ;

		SELECT
			jsonb_data || decrypted_jsonb
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