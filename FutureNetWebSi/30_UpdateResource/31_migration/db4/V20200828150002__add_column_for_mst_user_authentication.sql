--mst_user_authenticationに列を追加
ALTER TABLE
  mst_user_authentication
  ADD COLUMN IF NOT EXISTS user_password_history jsonb --パスワード履歴
;
COMMENT ON COLUMN "mst_user_authentication"."user_password_history" IS E'パスワード履歴';
