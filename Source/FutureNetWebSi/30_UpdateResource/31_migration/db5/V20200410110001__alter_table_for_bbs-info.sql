-- カラム追加
ALTER TABLE bbs_info
ADD COLUMN IF NOT EXISTS reg_func_class smallint;

-- コメント修正
COMMENT ON COLUMN "bbs_info"."reg_func_class" IS E'登録元機能';

-- 既存データ更新

update bbs_info
set reg_func_class = 0
where reg_func_class = null;