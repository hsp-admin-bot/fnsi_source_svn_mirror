DROP INDEX IF EXISTS "idx_ord_main_02";
CREATE INDEX "idx_ord_main_02" ON "ntss"."ord_main" USING btree (
  "facility_cd" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST,
  "rst_edition" "pg_catalog"."int4_ops" ASC NULLS LAST,
  "rst_dialysis_state" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
DROP INDEX IF EXISTS "idx_ord_main_03";
CREATE INDEX "idx_ord_main_03" ON "ntss"."ord_main" USING btree (
  "treat_date" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST,
  "facility_cd" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);
