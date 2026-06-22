ALTER TABLE
  mst_user_authentication
ADD COLUMN
  card_idm varchar(50)
;
COMMENT ON COLUMN "mst_user_authentication"."card_idm" IS 'アクセスカード番号';
