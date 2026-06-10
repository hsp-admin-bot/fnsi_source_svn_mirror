--mnt_device_edge_stateに列を追加
ALTER TABLE
  mnt_device_edge_state
  ADD COLUMN IF NOT EXISTS alive_moni_status_change_date timestamp(3) --死活監視ステータス変更日時
;
COMMENT ON COLUMN "mnt_device_edge_state"."alive_moni_status_change_date" IS E'死活監視ステータス変更日時';
