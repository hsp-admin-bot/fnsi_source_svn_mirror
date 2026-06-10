ALTER TABLE mst_pat_event_sub_category  ADD COLUMN IF NOT EXISTS fn_event_category_class VARCHAR(1);
COMMENT ON COLUMN "mst_pat_event_sub_category"."fn_event_category_class" IS 'FNW用サブカテゴリ区分';