--sys_coop_journalに列を追加
ALTER TABLE
  sys_coop_journal
  ADD COLUMN temp_content jsonb --臨時内容
;

COMMENT ON COLUMN "sys_coop_journal"."temp_content" IS E'臨時内容';
