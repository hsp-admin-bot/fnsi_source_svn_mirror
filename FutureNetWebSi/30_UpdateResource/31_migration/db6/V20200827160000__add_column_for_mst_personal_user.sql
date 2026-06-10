-- 利用者マスタに患者共有フラグ列を追加
ALTER TABLE 
 mst_personal_user
 ADD COLUMN IF NOT EXISTS patient_shared numeric NULL;

-- コメント修正
COMMENT ON COLUMN "mst_personal_user"."patient_shared" IS '患者共有フラグ';