DROP INDEX IF EXISTS "idx_ord_checklist_01";
CREATE INDEX "idx_ord_checklist_01" ON "ntss"."ord_checklist" USING btree (
  "ord_no" "pg_catalog"."int8_ops" ASC NULLS LAST,
  "facility_cd" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
