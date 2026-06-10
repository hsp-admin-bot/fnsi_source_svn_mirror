-- テーブル削除
DROP TABLE IF EXISTS log_json_comment;
-- テーブル作成
CREATE TABLE log_json_comment
(
    tbl_name character varying(50) NOT NULL,  --テーブル物理名
    col_name character varying(100) NOT NULL,  --コラム物理名
    json_key_name character varying(50) NOT NULL,  --Jsonキー物理名
    json_key_comment character varying(100),  --Jsonキー論理名
    CONSTRAINT unq_log_json_comment_01 PRIMARY KEY (tbl_name,col_name,json_key_name)
)
WITH (
    OIDS=FALSE
);
-- ユーザ設定
ALTER TABLE log_json_comment OWNER TO nkk6;
-- コメント追加
COMMENT ON TABLE "log_json_comment" IS E'Json論理名設定テーブル';
COMMENT ON COLUMN "log_json_comment"."tbl_name" IS E'テーブル物理名';
COMMENT ON COLUMN "log_json_comment"."col_name" IS E'コラム物理名';
COMMENT ON COLUMN "log_json_comment"."json_key_name" IS E'Jsonキー物理名';
COMMENT ON COLUMN "log_json_comment"."json_key_comment" IS E'Jsonキー論理名';