DROP INDEX IF EXISTS "idx_mni_monitor_02";
CREATE INDEX "idx_mni_monitor_02" ON "ntss"."mni_monitor" USING btree (
  "facility_cd" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST,
  "ord_no" "pg_catalog"."int8_ops" ASC NULLS LAST
);
DROP INDEX IF EXISTS "idx_mni_monitor_03";
CREATE INDEX "idx_mni_monitor_03" ON "ntss"."mni_monitor" USING btree (
  "occur_date" "pg_catalog"."timestamp_ops" ASC NULLS LAST,
  "facility_cd" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
