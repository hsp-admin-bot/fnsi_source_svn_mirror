-- インデックスの削除(装置動作記録)
DROP INDEX IF EXISTS "ntss"."idx_mnt_motion_record_03";
-- インデックスの追加(装置動作記録)
CREATE INDEX "idx_mnt_motion_record_03" ON "ntss"."mnt_motion_record" USING btree (
  "facility_cd" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST,
  "machine_type_cd" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST,
  "machine_serial" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST,
  "data_type" "pg_catalog"."numeric_ops" ASC NULLS LAST,
  "event_reg_date" "pg_catalog"."timestamp_ops" ASC NULLS LAST
);