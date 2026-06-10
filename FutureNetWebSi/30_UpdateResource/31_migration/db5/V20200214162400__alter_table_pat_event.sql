-- 項目追加
ALTER TABLE mst_pat_event_sub_category ADD COLUMN IF NOT EXISTS use_type smallint;
-- コメント追加
COMMENT ON COLUMN "mst_pat_event_sub_category"."use_type" IS E'利用種別';

-- 項目削除
ALTER TABLE mst_pat_event_data_template DROP COLUMN IF EXISTS is_va; -- VAフラグ
ALTER TABLE mst_pat_event_data_template DROP COLUMN IF EXISTS is_observe; -- 観察記録フラグ
ALTER TABLE mst_pat_event_data_template DROP COLUMN IF EXISTS is_intro_letter; -- 紹介状フラグ

-- 項目追加
ALTER TABLE pat_event ADD COLUMN IF NOT EXISTS use_type smallint;
ALTER TABLE pat_event ADD COLUMN IF NOT EXISTS event_end_date timestamp(3);

-- 項目削除
ALTER TABLE pat_event DROP COLUMN IF EXISTS is_va; -- VAフラグ
ALTER TABLE pat_event DROP COLUMN IF EXISTS is_observe; -- 観察記録フラグ
ALTER TABLE pat_event DROP COLUMN IF EXISTS is_intro_letter; -- 紹介状フラグ

-- コメント追加
COMMENT ON COLUMN "pat_event"."use_type" IS E'利用種別';
COMMENT ON COLUMN "pat_event"."event_date" IS E'イベント開始日時';
COMMENT ON COLUMN "pat_event"."event_end_date" IS E'イベント終了日時';
