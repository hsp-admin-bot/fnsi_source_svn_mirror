--mst_reportに列を追加
ALTER TABLE
  mst_report
  ADD COLUMN IF NOT EXISTS additional_info jsonb --追加情報
;
COMMENT ON COLUMN "mst_report"."additional_info" IS E'追加情報';
