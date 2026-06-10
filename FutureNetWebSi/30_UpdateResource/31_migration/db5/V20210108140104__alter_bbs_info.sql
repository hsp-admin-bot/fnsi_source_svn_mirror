ALTER TABLE ntss.bbs_info ADD COLUMN font_color character varying DEFAULT NULL;
COMMENT ON COLUMN "ntss"."bbs_info"."font_color" IS '施設カレンダーイベント文字色';