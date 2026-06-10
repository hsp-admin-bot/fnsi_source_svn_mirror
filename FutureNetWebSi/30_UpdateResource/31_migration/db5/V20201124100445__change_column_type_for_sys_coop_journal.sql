-- 型の修正
ALTER TABLE "sys_coop_journal" 
  ALTER COLUMN "base_date" TYPE varchar(10) USING "base_date"::varchar(10);

-- コメント修正
COMMENT ON COLUMN "sys_coop_journal"."base_date" IS '基準日';

-- データ修正
UPDATE sys_coop_journal
set base_date = replace(base_date,'-','');

-- 型の修正
ALTER TABLE "sys_coop_journal" 
  ALTER COLUMN "base_date" TYPE varchar(8) USING "base_date"::varchar(8);