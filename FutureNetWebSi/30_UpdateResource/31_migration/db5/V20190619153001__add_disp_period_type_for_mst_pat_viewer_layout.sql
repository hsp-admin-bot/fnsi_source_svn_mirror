ALTER TABLE
  mst_pat_viewer_layout
ADD COLUMN
  disp_period_class character varying(1)
;
COMMENT ON COLUMN "mst_pat_viewer_layout"."disp_period_class" IS E'表示期間区分';
