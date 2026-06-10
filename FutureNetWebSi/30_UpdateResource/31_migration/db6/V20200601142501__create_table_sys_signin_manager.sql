-- テーブル削除
DROP TABLE IF EXISTS sys_signin_manager;
-- テーブル作成
CREATE TABLE sys_signin_manager
(
    terminal_unique_string character varying(16) NOT NULL,  --端末固有文字列
    facility_cd character varying(6),  --施設コード
    user_id bigint,  --利用者ID
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3),  --更新日時
    CONSTRAINT unq_sys_signin_manager_01 PRIMARY KEY (terminal_unique_string)
);
-- コメント追加
COMMENT ON TABLE "sys_signin_manager" IS E'サインイン管理';
COMMENT ON COLUMN "sys_signin_manager"."terminal_unique_string" IS E'端末固有文字列';
COMMENT ON COLUMN "sys_signin_manager"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "sys_signin_manager"."user_id" IS E'利用者ID';
COMMENT ON COLUMN "sys_signin_manager"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "sys_signin_manager"."up_date" IS E'更新日時';
