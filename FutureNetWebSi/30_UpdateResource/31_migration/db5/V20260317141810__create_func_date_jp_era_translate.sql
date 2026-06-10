------------------------------------------------------------
-- 既存関数の削除
------------------------------------------------------------
DROP FUNCTION IF EXISTS ntss.date_jp_era_translate(integer);

------------------------------------------------------------
-- 和暦変換関数 (YYYYMMDD 形式の数値から和暦要素を抽出)
------------------------------------------------------------
CREATE OR REPLACE FUNCTION ntss.date_jp_era_translate(date_yyyymmdd integer)
 RETURNS TABLE(era_name text, era_code integer, era_year integer, month integer, day integer)
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
    era_record RECORD;
    yyyy INT;
    mm   INT;
    dd   INT;
BEGIN
    -- 元号データの定義と入力日付に該当する範囲の抽出
    SELECT *
      INTO era_record
      FROM (VALUES
        (1, '明治', 18680908, 19120729),
        (2, '大正', 19120730, 19261224),
        (3, '昭和', 19261225, 19890107),
        (4, '平成', 19890108, 20190430),
        (5, '令和', 20190501, 99999999)
      ) AS t(code, name, start_date, end_date)
     WHERE date_yyyymmdd BETWEEN start_date AND end_date;

    -- 該当する元号がない場合は何も返さない
    IF NOT FOUND THEN
        RETURN;
    END IF;

    -- 数値計算による年・月・日の切り出し
    yyyy := date_yyyymmdd / 10000;
    mm   := (date_yyyymmdd % 10000) / 100;
    dd   := date_yyyymmdd % 100;

    -- 返却値の設定
    era_name := era_record.name;
    era_code := era_record.code;
    era_year := yyyy - (era_record.start_date / 10000) + 1; -- 元年を1とする計算
    month    := mm;
    day      := dd;

    RETURN NEXT;
END;
$function$;

-- コメントも付けておくと A5M2 で見た時に親切です
COMMENT ON FUNCTION ntss.date_jp_era_translate(integer) IS '日付数値(YYYYMMDD)を和暦要素に変換する関数';