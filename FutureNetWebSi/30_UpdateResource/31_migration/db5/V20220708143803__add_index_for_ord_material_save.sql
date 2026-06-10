DROP INDEX IF EXISTS "idx_ord_material_save_01";
CREATE INDEX "idx_ord_material_save_01" ON "ntss"."ord_material_save" USING btree (
  "supplies_base_no" "pg_catalog"."int8_ops" ASC NULLS LAST
);