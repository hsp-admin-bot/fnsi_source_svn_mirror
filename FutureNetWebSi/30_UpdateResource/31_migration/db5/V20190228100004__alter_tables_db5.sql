---------------------------
-- 装置状態管理
---------------------------
-- 緊急発報件数
ALTER TABLE mnt_machine_state ALTER COLUMN m_notice_cnt SET DEFAULT 0;
-- 予防保守件数
ALTER TABLE mnt_machine_state ALTER COLUMN preventive_mainte_cnt SET DEFAULT 0;
-- 通信不良有無
ALTER TABLE mnt_machine_state ALTER COLUMN is_preventive_mainte SET DEFAULT 0;
-- 患者確認済みフラグ
ALTER TABLE mnt_machine_state ADD COLUMN is_pat_verified character varying(1) DEFAULT '0';
COMMENT ON COLUMN "mnt_machine_state"."is_pat_verified" IS E'患者確認済みフラグ';
-- 装置設定一時データ
ALTER TABLE mnt_machine_state ADD COLUMN tmp_device_set_info jsonb;
COMMENT ON COLUMN "mnt_machine_state"."tmp_device_set_info" IS E'装置設定一時データ';