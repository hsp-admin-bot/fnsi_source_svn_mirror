-- 加算情報
ALTER TABLE pat_exam_main ADD COLUMN IF NOT EXISTS is_order character varying(1);
-- コメント追加
COMMENT ON COLUMN "pat_exam_main"."is_order" IS E'検査依頼登録フラグ';
-- すべての既存レコードに「0」を入れる
update
  pat_exam_main
set
  is_order = '0';
-- 予定データのあるレコードのみに「1」を入れる
update
  pat_exam_main
set
  is_order = '1'
WHERE
  jsonb_typeof(exam_order_info) = 'array'
AND
  exam_order_info <> '[]';