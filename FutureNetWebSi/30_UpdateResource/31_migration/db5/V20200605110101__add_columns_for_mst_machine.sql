--mst_machineに列を追加
ALTER TABLE
  mst_machine
  ADD COLUMN IF NOT EXISTS is_support_blood_purify character varying(1)  --対応可否フラグ(特殊浄化)
;
COMMENT ON COLUMN "mst_machine"."is_support_blood_purify" IS E'対応可否フラグ(特殊浄化)';
