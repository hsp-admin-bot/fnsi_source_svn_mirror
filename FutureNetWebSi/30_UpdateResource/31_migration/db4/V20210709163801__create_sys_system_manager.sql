-- テーブル削除(システム設定)
DROP TABLE IF EXISTS sys_system_manager;
-- テーブル作成(WebSocket認証キー情報)
CREATE TABLE sys_system_manager
(
    ctl_no numeric(4) NOT NULL,
    name character varying(256), 
    value jsonb,
    description character varying(4000), 
    is_enable character varying(1), 
    up_date timestamp(3)
)
WITH (
    OIDS=FALSE
);
-- コメント追加(WebSocket認証キー情報)
COMMENT ON TABLE "sys_system_manager" IS E'システム設定';
COMMENT ON COLUMN "sys_system_manager"."ctl_no" IS E'管理番号';
COMMENT ON COLUMN "sys_system_manager"."name" IS E'名称';
COMMENT ON COLUMN "sys_system_manager"."value" IS E'値';
COMMENT ON COLUMN "sys_system_manager"."description" IS E'説明';
COMMENT ON COLUMN "sys_system_manager"."is_enable" IS E'編集可否フラグ';
COMMENT ON COLUMN "sys_system_manager"."up_date" IS E'更新日時';

INSERT INTO sys_system_manager (
  ctl_no, 
  name, 
  value, 
  description, 
  is_enable, 
  up_date
) VALUES (
  1, 
  ' 認証チェックしない経路', 
  '{"url": ["vpn.nksfn.com"]}', 
  'URLに指定されている値が存在する経路をチェックしない', 
  '1', 
  current_timestamp
);
