-- #2876 警報通知データにステータス追加
-- #2880 警報通知発生施設および装置のソート表示

-- 列の追加
ALTER TABLE mnt_machine_state
ADD COLUMN IF NOT EXISTS service_support_cnt integer DEFAULT 0;

-- コメント修正
COMMENT ON COLUMN "mnt_machine_state"."service_support_cnt" IS E'サービス対応件数';

