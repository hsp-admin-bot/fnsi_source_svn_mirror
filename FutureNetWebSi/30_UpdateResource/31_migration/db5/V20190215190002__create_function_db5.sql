-- Fnction: zenkana_translate(character varying)
CREATE OR REPLACE FUNCTION zenkana_translate(character varying)
 RETURNS text
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
  DECLARE
    text_result text := upper($1);
    hankaku_daku_kana text[] := array['ｳﾞ', 'ｶﾞ', 'ｷﾞ', 'ｸﾞ', 'ｹﾞ', 'ｺﾞ', 'ｻﾞ', 'ｼﾞ', 'ｽﾞ', 'ｾﾞ', 'ｿﾞ', 'ﾀﾞ', 'ﾁﾞ', 'ﾂﾞ', 'ﾃﾞ', 'ﾄﾞ', 'ﾊﾞ', 'ﾋﾞ', 'ﾌﾞ', 'ﾍﾞ', 'ﾎﾞ', 'ﾊﾟ', 'ﾋﾟ', 'ﾌﾟ', 'ﾍﾟ', 'ﾎﾟ'];
    zenkaku_daku_kana text[] := array['ヴ', 'ガ', 'ギ', 'グ', 'ゲ', 'ゴ', 'ザ', 'ジ', 'ズ', 'ゼ', 'ゾ', 'ダ', 'ヂ', 'ヅ', 'デ', 'ド', 'バ', 'ビ', 'ブ', 'ベ', 'ボ', 'パ', 'ピ', 'プ', 'ペ', 'ポ'];

    text_hankaku_kana text := 'ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜｦﾝｧｨｩｪｫｯｬｭｮ';
    text_zenkaku_hira text := 'あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをんぁぃぅぇぉっゃゅょ';
    text_zenkaku_kana text := 'アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンァィゥェォッャュョ';
    text_zenkaku_daku_hira text := 'がぎぐげござじずぜぞだぢづでどばびぶべぼぱぴぷぺぽ';
    text_zenkaku_daku_kana text := 'ガギグゲゴザジズゼゾダヂヅデドバビブベボパピプペポ';
    text_zenkaku_nums text := '０１２３４５６７８９';
    text_hankaku_nums text := '0123456789';
    text_zenkaku_upper_alphabets text := 'ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ';
    text_zenkaku_lower_alphabets text := 'ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ';
    text_hankaku_upper_alphabets text := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  BEGIN
    -- 入力値が空の場合処理を抜ける
    IF $1 IS null OR $1 = '' THEN
      RETURN $1;
    END IF;

    -- 濁点付きの半カナをリプレース → 半角を全角に置き換えている
    -- 濁点は2文字扱いの為、translateの前に実施する必要がある
    FOR i IN 1..array_length(hankaku_daku_kana, 1) LOOP
      text_result := replace(text_result, hankaku_daku_kana[i], zenkaku_daku_kana[i]);
    END LOOP;

    -- translate で置き換え
    text_result := translate(
      text_result
      , text_hankaku_kana || text_zenkaku_hira || text_zenkaku_daku_hira || text_zenkaku_upper_alphabets || text_zenkaku_lower_alphabets
      , text_zenkaku_kana || text_zenkaku_kana || text_zenkaku_daku_kana || text_hankaku_upper_alphabets || text_hankaku_upper_alphabets
    );

    RETURN text_result;

  END;
$function$