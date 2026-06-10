-- 列の追加
ALTER TABLE sys_master_define 
ADD COLUMN IF NOT EXISTS system_use_disp character varying(1);

-- コメント修正
COMMENT ON COLUMN "sys_master_define"."system_use_disp" IS E'システム利用表示区分';