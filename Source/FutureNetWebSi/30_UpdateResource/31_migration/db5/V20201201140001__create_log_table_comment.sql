DROP TABLE IF EXISTS log_table_comment;
-- テーブル作成
CREATE TABLE log_table_comment
(
    tbl_name character varying(50) NOT NULL,  --テーブル物理名
    tbl_comment character varying(100) NOT NULL,  --テーブル論理名
    col_name character varying(50),  --コラム物理名
    col_comment character varying(100),  --コラム論理名
    json_flg character varying(1),  --JSONフラグ
    keystep numeric,  --キーステップ
    CONSTRAINT unq_log_table_comment_01 PRIMARY KEY (tbl_name,col_name)
)
WITH (
    OIDS=FALSE
);
-- ユーザ設定
ALTER TABLE log_table_comment OWNER TO nkk5;
-- コメント追加
COMMENT ON TABLE "log_table_comment" IS E'テーブル論理名設定テーブル';
COMMENT ON COLUMN "log_table_comment"."tbl_name" IS E'テーブル物理名';
COMMENT ON COLUMN "log_table_comment"."tbl_comment" IS E'テーブル論理名';
COMMENT ON COLUMN "log_table_comment"."col_name" IS E'コラム物理名';
COMMENT ON COLUMN "log_table_comment"."col_comment" IS E'コラム論理名';
COMMENT ON COLUMN "log_table_comment"."json_flg" IS E'JSONフラグ';
COMMENT ON COLUMN "log_table_comment"."keystep" IS E'キーステップ';