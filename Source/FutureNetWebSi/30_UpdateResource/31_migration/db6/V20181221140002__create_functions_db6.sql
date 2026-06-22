-- 暗号化ファンクション登録
CREATE OR REPLACE FUNCTION personal_info_encrypt (inData TEXT)
 RETURNS TEXT AS
'
DECLARE
  hexStr TEXT;
  bitStr TEXT;
  loopCnt INTEGER;
  startIndex INTEGER;
BEGIN
  -- 処理
  IF inData IS NOT NULL THEN
    -- テキスト ⇒ bytea型データ ⇒ bit型データ ⇒ ビットシフト処理
    bitStr := substr((substr(inData::bytea::text, 2)::varbit)::text, 2) || substr((substr(inData::bytea::text, 2)::varbit)::text, 1, 1);
    -- ループ回数の算出
    loopCnt := length(bitStr) / 4;
    IF 1 > loopCnt THEN
       -- ループ回数が0の場合
       return NULL;
    END IF;

    startIndex := 1;
    -- 16進数形式の文字列を作成
    FOR i IN 1..loopCnt LOOP
      -- 4bit単位で文字に変換＆文字列結合
      hexStr := concat(hexStr, to_hex(substr(bitStr, startIndex, 4)::bit(4)::int));
      startIndex := startIndex + 4;
    END LOOP;
  END IF;

  return hexStr;
END;
'
LANGUAGE 'plpgsql';

-- 復号化ファンクション登録
CREATE OR REPLACE FUNCTION personal_info_decrypt (inData TEXT)
 RETURNS TEXT AS
'
DECLARE
  outData TEXT;
  hexStr TEXT;
  bitStr TEXT;
  loopCnt INTEGER;
  startIndex INTEGER;
BEGIN
  -- 処理
  IF inData IS NOT NULL THEN
    -- 16進数形式の文字列 ⇒ 2進数形式の文字列
    bitStr := (''x'' || inData)::varbit::text;
    -- ビットシフトを元に戻す
    bitStr := substr(bitStr, length(bitStr)) || substr(bitStr, 1, length(bitStr)-1);
    -- ループ回数の算出
    loopCnt := length(bitStr) / 4;
    IF 1 > loopCnt THEN
       -- ループ回数が０の場合
       return NULL;
    END IF;

    startIndex := 1;
    -- 16進数形式の文字列を作成
    FOR i IN 1..loopCnt LOOP
      -- 4bit単位で文字に変換＆文字列結合
      hexStr := concat(hexStr, to_hex(substr(bitStr, startIndex, 4)::bit(4)::int));
      startIndex := startIndex + 4;
    END LOOP;
    -- 16進数形式の文字列 ⇒ bytea型データ ⇒ UTF8形式の文字列
    SELECT convert_from(decode(hexStr, ''hex''), ''UTF8'') INTO outData;
  END IF;

  return outData;
END;
'
LANGUAGE 'plpgsql';
