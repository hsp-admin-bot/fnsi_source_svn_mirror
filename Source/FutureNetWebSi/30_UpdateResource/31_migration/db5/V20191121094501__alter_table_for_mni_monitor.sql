--------------------------------------------------
-- 装置モニタデータテーブルに更新者IDを追加
--------------------------------------------------
-- 項目追加
ALTER TABLE mni_monitor ADD COLUMN upd_staff_id bigint;
-- コメント追加
COMMENT ON COLUMN "mni_monitor"."upd_staff_id" IS E'更新者ID';
