-- 保険情報テーブルに保険メモカラム追加
ALTER TABLE
  pat_insurance
ADD COLUMN memo1 character varying;

ALTER TABLE
  pat_insurance
ADD COLUMN memo2 character varying;

COMMENT ON COLUMN "pat_insurance"."memo1" IS E'保険メモ１';
COMMENT ON COLUMN "pat_insurance"."memo2" IS E'保険メモ２';