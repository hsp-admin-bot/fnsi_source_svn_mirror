ALTER TABLE ntss.mst_user ADD login_method varchar(1) NULL;
COMMENT ON COLUMN ntss.mst_user.login_method IS '登録方式';