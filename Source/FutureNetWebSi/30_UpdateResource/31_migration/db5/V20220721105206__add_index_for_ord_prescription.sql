DROP INDEX IF EXISTS "idx_ord_prescription_01";
CREATE INDEX "idx_ord_prescription_01" ON "ntss"."ord_prescription" USING btree (
  "facility_cd" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST,
  "pat_id" "pg_catalog"."int8_ops" ASC NULLS LAST
);
