--mst_pat_event_sub_categoryに列を追加
ALTER TABLE "ntss"."mst_pat_event_sub_category"
	ADD COLUMN "disp_item_info" jsonb;
COMMENT ON COLUMN "mst_pat_event_sub_category"."disp_item_info" IS 'レポート一覧';
