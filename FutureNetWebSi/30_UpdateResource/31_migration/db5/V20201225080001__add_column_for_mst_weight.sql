ALTER TABLE ntss.mst_weight ADD telegram_format jsonb NULL;
COMMENT ON COLUMN ntss.mst_weight.telegram_format IS '電文フォーマット';
