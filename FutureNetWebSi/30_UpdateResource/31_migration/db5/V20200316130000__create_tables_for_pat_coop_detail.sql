-- テーブル削除
DROP TABLE IF EXISTS pat_coop_detail;

-- テーブル作成
CREATE TABLE pat_coop_detail
(
	coop_save_no bigserial NOT NULL, -- 管理番号
	facility_cd character varying(6) NOT NULL, -- 施設コード
	pat_id bigint NOT NULL, -- 患者番号
	save_1 jsonb, -- 連携情報カラム1
	save_2 jsonb, -- 連携情報カラム2
	save_3 jsonb, -- 連携情報カラム3
	save_4 jsonb, -- 連携情報カラム4
	save_5 jsonb, -- 連携情報カラム5
	save_6 jsonb, -- 連携情報カラム1
	save_7 jsonb, -- 連携情報カラム2
	save_8 jsonb, -- 連携情報カラム3
	save_9 jsonb, -- 連携情報カラム4
	save_10 jsonb, -- 連携情報カラム5
	is_disp character varying(1) DEFAULT '1', -- 表示フラグ
	is_del character varying(1) DEFAULT '0', -- 削除フラグ
	user_id bigint, -- 操作者ID
	up_date timestamp(3),  --更新日時
	reg_date timestamp(3),  --登録日時
	CONSTRAINT unq_pat_coop_detail_01 PRIMARY KEY (coop_save_no)
)
WITH (
    OIDS=FALSE
);

-- コメント
COMMENT ON TABLE "pat_coop_detail" IS E'患者連携情報';
COMMENT ON COLUMN "pat_coop_detail"."coop_save_no" IS E'管理番号';
COMMENT ON COLUMN "pat_coop_detail"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "pat_coop_detail"."pat_id" IS E'患者番号';
COMMENT ON COLUMN "pat_coop_detail"."save_1" IS E'連携情報カラム1';
COMMENT ON COLUMN "pat_coop_detail"."save_2" IS E'連携情報カラム2';
COMMENT ON COLUMN "pat_coop_detail"."save_3" IS E'連携情報カラム3';
COMMENT ON COLUMN "pat_coop_detail"."save_4" IS E'連携情報カラム4';
COMMENT ON COLUMN "pat_coop_detail"."save_5" IS E'連携情報カラム5';
COMMENT ON COLUMN "pat_coop_detail"."save_6" IS E'連携情報カラム6';
COMMENT ON COLUMN "pat_coop_detail"."save_7" IS E'連携情報カラム7';
COMMENT ON COLUMN "pat_coop_detail"."save_8" IS E'連携情報カラム8';
COMMENT ON COLUMN "pat_coop_detail"."save_9" IS E'連携情報カラム9';
COMMENT ON COLUMN "pat_coop_detail"."save_10" IS E'連携情報カラム10';
COMMENT ON COLUMN "pat_coop_detail"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "pat_coop_detail"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "pat_coop_detail"."user_id" IS E'操作者ID';
COMMENT ON COLUMN "pat_coop_detail"."up_date" IS E'更新日時';
COMMENT ON COLUMN "pat_coop_detail"."reg_date" IS E'登録日時';
