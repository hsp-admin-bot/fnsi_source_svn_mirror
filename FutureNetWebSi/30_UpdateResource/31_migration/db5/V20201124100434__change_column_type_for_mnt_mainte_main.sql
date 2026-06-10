-- 型の修正
ALTER TABLE "mnt_mainte_main" 
  ALTER COLUMN "mainte_date" TYPE timestamp(3) USING "mainte_date"::timestamp(3);

-- コメント修正
COMMENT ON COLUMN "mnt_mainte_main"."mainte_class" IS '検査型式';