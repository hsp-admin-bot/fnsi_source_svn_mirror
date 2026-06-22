-- mst_personal_user のNOT NULL制約を削除

-- メールアドレス１
ALTER TABLE mst_personal_user ALTER COLUMN user_email_address_1 DROP NOT NULL;

-- 職種コード
ALTER TABLE mst_personal_user ALTER COLUMN job_cd DROP NOT NULL;
