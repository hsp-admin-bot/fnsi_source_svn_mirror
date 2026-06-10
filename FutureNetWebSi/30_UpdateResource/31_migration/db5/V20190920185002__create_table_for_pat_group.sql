-- テーブル削除（患者グループ）
DROP TABLE IF EXISTS pat_group;
-- テーブル作成（患者グループ）
CREATE TABLE pat_group
(
	pat_group_cd bigserial NOT NULL,  --患者グループコード
	pat_group_name character varying COLLATE "pg_catalog"."default",--患者グループ名
	facility_cd character varying(6) COLLATE "pg_catalog"."default" NOT NULL,--施設コード
	is_disp character varying(1) DEFAULT '1',  --表示フラグ
	is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3)  --更新日時
);
-- コメント追加（患者グループ）
COMMENT ON TABLE "pat_group" IS E'患者グループ';
COMMENT ON COLUMN "pat_group"."pat_group_cd" IS E'患者グループコード';
COMMENT ON COLUMN "pat_group"."pat_group_name" IS E'患者グループ名';
COMMENT ON COLUMN "pat_group"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "pat_group"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "pat_group"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "pat_group"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "pat_group"."up_date" IS E'更新日時';


-- テーブル削除（患者グループ詳細）
DROP TABLE IF EXISTS pat_group_detail;
-- テーブル作成（患者グループ詳細）
CREATE TABLE pat_group_detail
(
    pat_group_cd bigint NOT NULL,  --患者グループコード
	pat_id bigint NOT NULL  --患者ID
);
-- コメント追加（患者グループ詳細）
COMMENT ON TABLE "pat_group_detail" IS E'患者グループ詳細';
COMMENT ON COLUMN "pat_group_detail"."pat_group_cd" IS E'患者グループコード';
COMMENT ON COLUMN "pat_group_detail"."pat_id" IS E'患者ID';