DROP INDEX IF EXISTS "ntss"."idx_mst_medicine_01";
CREATE INDEX "idx_mst_medicine_01" ON "ntss"."mst_medicine" USING btree ( "facility_cd" );