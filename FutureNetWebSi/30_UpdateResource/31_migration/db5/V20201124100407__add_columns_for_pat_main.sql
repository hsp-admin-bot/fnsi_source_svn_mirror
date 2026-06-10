-- pat_mainに列を追加
ALTER TABLE
  pat_main
ADD COLUMN card_idm character varying;

-- コメント追加
COMMENT ON COLUMN "pat_main"."card_idm" IS 'アクセスカード番号';