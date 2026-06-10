--mst_reportに列を追加
ALTER TABLE
  mst_report
ADD COLUMN disp_order integer NOT NULL DEFAULT 0 --表示順
;

COMMENT ON COLUMN "mst_report"."disp_order" IS E'表示順';
