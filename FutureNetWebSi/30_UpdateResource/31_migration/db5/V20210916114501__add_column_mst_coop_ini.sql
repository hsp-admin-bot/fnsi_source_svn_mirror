--mst_coop_iniに列を追加
ALTER TABLE  mst_coop_ini ADD COLUMN key_mapping jsonb;

-- コメント追加
COMMENT ON COLUMN "mst_coop_ini"."key_mapping" IS E'KEYマッピング';
