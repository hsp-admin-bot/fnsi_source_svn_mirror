--mnt_machine_stateに列を追加
ALTER TABLE
  mnt_machine_state
ADD COLUMN monitor_data jsonb  --モニタデータ
;


COMMENT ON COLUMN "mnt_machine_state"."monitor_data" IS E'モニタデータ';