--mst_personal_userに列を追加
ALTER TABLE pat_personal_main ADD COLUMN remote_monitor_service integer;  --遠隔モニタリングサービス業者
ALTER TABLE pat_personal_main ADD COLUMN remote_monitor_user_id character varying;  --遠隔モニタリングサービス利用者ID
ALTER TABLE pat_personal_main ADD COLUMN remote_monitor_user_pw character varying;  --遠隔モニタリングサービス利用者パスワード

COMMENT ON COLUMN "pat_personal_main"."remote_monitor_service" IS E'遠隔モニタリングサービス業者';
COMMENT ON COLUMN "pat_personal_main"."remote_monitor_user_id" IS E'遠隔モニタリングサービス利用者ID';
COMMENT ON COLUMN "pat_personal_main"."remote_monitor_user_pw" IS E'遠隔モニタリングサービス利用者パスワード';