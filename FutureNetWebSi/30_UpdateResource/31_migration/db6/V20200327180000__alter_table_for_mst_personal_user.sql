-- 列の削除
ALTER TABLE mst_personal_user
DROP COLUMN IF EXISTS info_disp_to_admin;

-- 列の追加
ALTER TABLE mst_personal_user
ADD COLUMN IF NOT EXISTS info_disp_to_admin character varying(1) DEFAULT '0';

-- コメント修正
COMMENT ON COLUMN "mst_personal_user"."info_disp_to_admin" IS E'管理者への表示許可';
