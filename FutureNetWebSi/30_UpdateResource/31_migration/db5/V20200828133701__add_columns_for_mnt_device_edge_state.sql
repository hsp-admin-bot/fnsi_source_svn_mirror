--mnt_device_edge_stateに列を追加
ALTER TABLE
  mnt_device_edge_state
  ADD COLUMN IF NOT EXISTS manage_no integer --予約更新指示番号
  ,
  ADD COLUMN IF NOT EXISTS manage_plan_date timestamp(3) --予約更新日時
;
COMMENT ON COLUMN "mnt_device_edge_state"."manage_no" IS E'予約更新指示番号';
COMMENT ON COLUMN "mnt_device_edge_state"."manage_plan_date" IS E'予約更新日時';
