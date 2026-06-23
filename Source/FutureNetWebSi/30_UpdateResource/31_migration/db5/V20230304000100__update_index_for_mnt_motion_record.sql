DROP INDEX IF EXISTS "ntss"."idx_mnt_motion_record_01";

CREATE INDEX "idx_mnt_motion_record_01" ON "ntss"."mnt_motion_record" USING btree (
  "facility_cd" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST,
  "machine_type_cd" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST,
  "machine_serial" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST,
  "data_type" "pg_catalog"."numeric_ops" ASC NULLS LAST
);
