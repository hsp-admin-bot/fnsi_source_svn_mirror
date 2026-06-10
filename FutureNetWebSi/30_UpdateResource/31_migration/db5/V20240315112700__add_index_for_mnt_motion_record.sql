-- インデックスの削除(装置動作記録)
DROP INDEX IF EXISTS "ntss"."idx_mnt_motion_record_05";
-- インデックスの追加(装置動作記録)
CREATE INDEX "idx_mnt_motion_record_05" ON "ntss"."mnt_motion_record" USING btree ("machine_record_cd");