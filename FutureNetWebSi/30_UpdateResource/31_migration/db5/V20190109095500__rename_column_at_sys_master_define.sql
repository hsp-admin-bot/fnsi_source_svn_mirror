-- 列名の修正
ALTER TABLE sys_master_define RENAME COLUMN master_type TO mode;

-- コメント修正
COMMENT ON COLUMN "sys_master_define"."mode" IS 'マスタ編集画面の起動方法';

-- mode=3となっている場合は、mode=2に更新する。
UPDATE sys_master_define SET mode='2' WHERE mode='3';
