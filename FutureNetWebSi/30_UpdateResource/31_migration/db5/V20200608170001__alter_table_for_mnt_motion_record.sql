-- #2876 警報通知データにステータス追加
-- #2880 警報通知発生施設および装置のソート表示

-- 列の追加
ALTER TABLE mnt_motion_record
ADD COLUMN IF NOT EXISTS is_correction_up_date timestamp(3),
ADD COLUMN IF NOT EXISTS service_support_type character varying(1) DEFAULT '0',
ADD COLUMN IF NOT EXISTS service_support_user_id bigint,
ADD COLUMN IF NOT EXISTS service_support_up_date timestamp(3);

-- コメント修正
COMMENT ON COLUMN "mnt_motion_record"."is_correction_up_date" IS E'対処日時';
COMMENT ON COLUMN "mnt_motion_record"."service_support_type" IS E'サービス対応種別';
COMMENT ON COLUMN "mnt_motion_record"."service_support_user_id" IS E'サービス対応者ID';
COMMENT ON COLUMN "mnt_motion_record"."service_support_up_date" IS E'サービス対応日時';
