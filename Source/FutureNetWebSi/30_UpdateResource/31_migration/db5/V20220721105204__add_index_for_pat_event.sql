DROP INDEX IF EXISTS "idx_pat_event_01";
CREATE INDEX "idx_pat_event_01" ON "ntss"."pat_event" USING btree (
  "pat_id" "pg_catalog"."int8_ops" ASC NULLS LAST,
  "facility_cd" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
