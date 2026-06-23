-- テーブル削除
DROP TABLE IF EXISTS mst_url_link_register;
-- テーブル作成
CREATE TABLE mst_url_link_register
(
  url_cd bigserial NOT NULL,  --URLコード
  facility_cd character varying(6) NOT NULL,  --施設コード
  function_name character varying(256) NOT NULL,  --関数名
  url_info jsonb NOT NULL, --URL
  is_disp character varying(1) DEFAULT '1',  --表示フラグ
  is_del character varying(1) DEFAULT '0',  --削除フラグ
  reg_date timestamp(3),  --登録日時
  up_date timestamp(3),  --更新日時
  CONSTRAINT unq_mst_url_link_register_01 PRIMARY KEY (url_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "mst_url_link_register" IS E'外部リンクメニューマスタ';
COMMENT ON COLUMN "mst_url_link_register"."url_cd" IS E'URLコード';
COMMENT ON COLUMN "mst_url_link_register"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_url_link_register"."function_name" IS E'関数名';
COMMENT ON COLUMN "mst_url_link_register"."url_info" IS E'URL';
COMMENT ON COLUMN "mst_url_link_register"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_url_link_register"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_url_link_register"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_url_link_register"."up_date" IS E'更新日時';