CREATE OR REPLACE FUNCTION ntss.address_data_type_translate(text_result text, address_flag boolean)
 RETURNS text
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
-- address_flag  true: カタカナ->ひらがな  半角->全角   false:ひらがな->カタカナ  全角->半角 
DECLARE
  hankaku_daku_kana text[] := array['ｳﾞ', 'ｶﾞ', 'ｷﾞ', 'ｸﾞ', 'ｹﾞ', 'ｺﾞ', 'ｻﾞ', 'ｼﾞ', 'ｽﾞ', 'ｾﾞ', 'ｿﾞ', 'ﾀﾞ', 'ﾁﾞ', 'ﾂﾞ', 'ﾃﾞ', 'ﾄﾞ', 'ﾊﾞ', 'ﾋﾞ', 'ﾌﾞ', 'ﾍﾞ', 'ﾎﾞ', 'ﾊﾟ', 'ﾋﾟ', 'ﾌﾟ', 'ﾍﾟ', 'ﾎﾟ'];
  zenkaku_daku_kana text[] := array['ヴ', 'ガ', 'ギ', 'グ', 'ゲ', 'ゴ', 'ザ', 'ジ', 'ズ', 'ゼ', 'ゾ', 'ダ', 'ヂ', 'ヅ', 'デ', 'ド', 'バ', 'ビ', 'ブ', 'ベ', 'ボ', 'パ', 'ピ', 'プ', 'ペ', 'ポ'];

  text_hankaku_kana text := 'ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜｦﾝｧｨｩｪｫｯｬｭｮ';
  text_zenkaku_hira text := 'あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをんぁぃぅぇぉっゃゅょ';
  text_zenkaku_kana text := 'アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンァィゥェォッャュョ';
  text_zenkaku_daku_hira text := 'がぎぐげござじずぜぞだぢづでどばびぶべぼぱぴぷぺぽ';
  text_zenkaku_daku_kana text := 'ガギグゲゴザジズゼゾダヂヅデドバビブベボパピプペポ';
BEGIN
  -- 入力値が空の場合処理を抜ける
  IF text_result IS null OR text_result = '' THEN
    RETURN text_result;
  END IF;
   
  IF address_flag THEN
    -- 濁点付きの半カナをリプレース → 半角を全角に置き換えている
    -- 濁点は2文字扱いの為、translateの前に実施する必要がある
    FOR i IN 1..array_length(hankaku_daku_kana, 1) LOOP
      text_result := replace(text_result, hankaku_daku_kana[i], zenkaku_daku_kana[i]);
    END LOOP;

    -- translate で置き換え
    text_result := translate(
      text_result
      , text_hankaku_kana || text_zenkaku_kana || text_zenkaku_daku_kana
      , text_zenkaku_hira || text_zenkaku_hira || text_zenkaku_daku_hira
    );
  ELSE 
    -- translate で置き換え
    text_result := translate(
      text_result
      , text_zenkaku_hira || text_zenkaku_kana || text_zenkaku_daku_hira
      , text_hankaku_kana || text_hankaku_kana || text_zenkaku_daku_kana
    );

    -- 濁点付きの全カナをリプレース → 全角を半角に置き換えている
    -- 濁点は2文字扱いの為、translateの前に実施する必要がある
    FOR i IN 1..array_length(zenkaku_daku_kana, 1) LOOP
      text_result := replace(text_result, zenkaku_daku_kana[i], hankaku_daku_kana[i]);
    END LOOP;

  END IF;

  RETURN text_result;

END;
$function$
;
