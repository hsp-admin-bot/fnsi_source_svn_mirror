--mst_userに列を追加
ALTER TABLE
  mst_user
  ADD COLUMN IF NOT EXISTS reg_password_date timestamp(3) without time zone --パスワード変更日時
;
COMMENT ON COLUMN "mst_user"."reg_password_date" IS E'パスワード変更日時';

--初期値を設定現在時刻に
update mst_user set reg_password_date = current_timestamp where is_disp = '1' and is_del = '0';
