--sys_master_defineに列を追加
ALTER TABLE
  sys_master_define
ADD COLUMN edit_level character varying(1)  --表示管理レベル
;

-- コメント追加（マスタ定義）
COMMENT ON COLUMN "sys_master_define"."edit_level" IS E'表示管理レベル';
