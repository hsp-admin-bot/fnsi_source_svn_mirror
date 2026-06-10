--sys_coop_journalに列を追加する
ALTER TABLE sys_coop_journal DROP COLUMN ope_id;

ALTER TABLE
  sys_coop_journal
ADD COLUMN IF NOT EXISTS ope_cd character varying(6) --操作番号
;

COMMENT ON COLUMN "sys_coop_journal"."ope_cd" IS E'操作番号';

