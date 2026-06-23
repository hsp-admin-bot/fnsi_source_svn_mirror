-- インデックスの削除(装置動作記録)
DROP INDEX IF EXISTS "ntss"."idx_mnt_motion_record_04";
-- インデックスの追加(装置動作記録)
CREATE INDEX "idx_mnt_motion_record_04" ON "ntss"."mnt_motion_record" USING btree (
  "event_reg_date" "pg_catalog"."timestamp_ops" ASC NULLS LAST
);
