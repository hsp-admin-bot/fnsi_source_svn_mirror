DROP INDEX IF EXISTS "ntss"."idx_ord_material_save_02";
CREATE INDEX "idx_ord_material_save_02" ON "ntss"."ord_material_save" USING btree ( "facility_cd" );
