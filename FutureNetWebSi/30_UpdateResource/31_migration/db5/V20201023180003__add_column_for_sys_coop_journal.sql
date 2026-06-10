--sys_coop_journalに列を追加する
ALTER TABLE
  sys_coop_journal
ADD COLUMN IF NOT EXISTS ope_id character varying(6) --操作番号
;

COMMENT ON COLUMN "sys_coop_journal"."ope_id" IS E'操作番号';

