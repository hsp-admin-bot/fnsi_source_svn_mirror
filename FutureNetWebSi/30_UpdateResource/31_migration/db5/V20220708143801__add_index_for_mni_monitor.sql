DROP INDEX IF EXISTS "idx_mni_monitor_02";
CREATE INDEX "idx_mni_monitor_02" ON "ntss"."mni_monitor" USING btree (
  "ord_no" "pg_catalog"."int8_ops" ASC NULLS LAST
);