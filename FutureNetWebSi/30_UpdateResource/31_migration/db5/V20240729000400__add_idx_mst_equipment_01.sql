DROP INDEX IF EXISTS "ntss"."idx_mst_equipment_01";
CREATE INDEX "idx_mst_equipment_01" ON "ntss"."mst_equipment" USING btree ( "facility_cd" );