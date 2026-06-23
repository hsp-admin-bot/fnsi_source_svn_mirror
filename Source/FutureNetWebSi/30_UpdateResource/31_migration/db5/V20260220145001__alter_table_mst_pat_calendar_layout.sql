-- #10419 患者カレンダー表示内容修正
-- 表示区分(disp_class) 列追加
ALTER TABLE mst_pat_calendar_layout
ADD COLUMN IF NOT EXISTS disp_class character varying(1);

-- コメント修正
COMMENT ON COLUMN "mst_pat_calendar_layout"."disp_class" IS E'表示区分';
