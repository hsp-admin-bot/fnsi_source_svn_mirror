--サインイン日時を追加
ALTER TABLE
  mst_personal_user
  ADD COLUMN IF NOT EXISTS signin_date timestamp(3);
  
--サインイン日時
COMMENT ON COLUMN "mst_personal_user"."signin_date" IS E'サインイン日時';
