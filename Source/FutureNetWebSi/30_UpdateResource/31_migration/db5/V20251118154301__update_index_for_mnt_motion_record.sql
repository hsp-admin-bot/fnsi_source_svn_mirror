DROP INDEX IF EXISTS "ntss"."idx_mnt_motion_record_04";

CREATE INDEX "idx_mnt_motion_record_04" ON "ntss"."mnt_motion_record" USING btree (
  "event_reg_date" "pg_catalog"."timestamp_ops" ASC NULLS LAST,
  "facility_cd" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST,
  "data_type" "pg_catalog"."numeric_ops" ASC NULLS LAST
);
