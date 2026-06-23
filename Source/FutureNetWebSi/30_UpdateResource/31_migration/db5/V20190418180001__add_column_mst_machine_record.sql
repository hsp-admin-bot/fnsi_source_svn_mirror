-- mst_machine_recordに列を追加
ALTER TABLE
  mst_machine_record
ADD COLUMN is_default character varying(1) NOT NULL DEFAULT '1',
ADD COLUMN log_class character varying(1),
ADD COLUMN target_model character varying(1)
;

-- コメント追加
COMMENT ON COLUMN "mst_machine_record"."is_default" IS E'推奨項目（0：非対象、1：対象）';
COMMENT ON COLUMN "mst_machine_record"."log_class" IS E'ログ分類（1：警報、2：報知、3：テスト、4：工程変更、5：操作、6：その他）';
COMMENT ON COLUMN "mst_machine_record"."target_model" IS E'対象機種（1：共通、2：RO装置、3：溶解装置、4：供給装置、5：透析装置、6：その他）';
