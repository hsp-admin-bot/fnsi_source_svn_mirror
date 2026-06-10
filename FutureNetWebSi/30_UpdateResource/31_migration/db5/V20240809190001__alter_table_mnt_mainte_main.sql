--列の削除
ALTER TABLE mnt_mainte_main
DROP COLUMN IF EXISTS mainte_ans_2,
DROP COLUMN IF EXISTS mainte_comment_2;

-- コメント修正
COMMENT ON COLUMN "mnt_mainte_main"."mainte_comment_1" IS E'定期点検者コメント';