ALTER TABLE pat_ind_approve
  ADD COLUMN IF NOT EXISTS is_content_changed_for_map VARCHAR(1) DEFAULT '0',
  ADD COLUMN IF NOT EXISTS content_for_map jsonb;

-- コメント修正
COMMENT ON COLUMN "pat_ind_approve"."is_content_changed_for_map" IS E'治療状況マップ指示変更ありフラグ';
COMMENT ON COLUMN "pat_ind_approve"."content_for_map" IS E'治療状況マップ確認時指示内容';
