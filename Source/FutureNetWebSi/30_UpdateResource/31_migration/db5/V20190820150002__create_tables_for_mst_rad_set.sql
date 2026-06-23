-- テーブル削除
DROP TABLE IF EXISTS mst_rad_set;
-- テーブル作成
CREATE TABLE mst_rad_set
(
    rad_set_cd bigserial NOT NULL,  --システムで管理する一意な放射線検査セットコード
    facility_cd character varying(6) NOT NULL,  --施設コード
    fn_exam_set_cd character varying(4),  --FNW+で管理する施設内の一意な検査セットコード
    rad_set_name character varying(40) NOT NULL,  --放射線検査セット名
    rad_set_abb_name character varying(40),  --省略 放射線検査セット名
    rad_item_info jsonb NOT NULL DEFAULT
    '[
        {
            "ctl_no":1,
            "ctl_name":null,
            "item_cd":null
        },
        {
            "ctl_no":2,
            "ctl_name":null,
            "item_cd":null
        },
        {
            "ctl_no":3,
            "ctl_name":null,
            "item_cd":null
        },
        {
            "ctl_no":4,
            "ctl_name":null,
            "item_cd":null
        },
        {
            "ctl_no":5,
            "ctl_name":null,
            "item_cd":null
        },
        {
            "ctl_no":6,
            "ctl_name":null,
            "item_cd":null
        }
    ]',  --放射線検査項目情報
	in_hospital_cd1 character varying(20),  --院内コード1
    sbt_cd1 character varying(20),  --属性コード1
    in_hospital_cd2 character varying(20),  --院内コード2
    sbt_cd2 character varying(20),  --属性コード2
    in_hospital_cd3 character varying(20),  --院内コード3
    sbt_cd3 character varying(20),  --属性コード3
    is_disp character varying(1) DEFAULT '1',  --表示フラグ
    is_del character varying(1) DEFAULT '0',  --削除フラグ
    reg_date timestamp(3),  --登録日時
    up_date timestamp(3), --更新日時
	CONSTRAINT unq_mst_rad_set_01 PRIMARY KEY (rad_set_cd)

)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "mst_rad_set" IS E'放射線検査セットマスタ';
COMMENT ON COLUMN "mst_rad_set"."rad_set_cd" IS E'システムで管理する一意な放射線検査セットコード';
COMMENT ON COLUMN "mst_rad_set"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_rad_set"."fn_exam_set_cd" IS E'FNW+で管理する施設内の一意な検査セットコード';
COMMENT ON COLUMN "mst_rad_set"."rad_set_name" IS E'放射線検査セット名';
COMMENT ON COLUMN "mst_rad_set"."rad_set_abb_name" IS E'省略 放射線検査セット名';
COMMENT ON COLUMN "mst_rad_set"."rad_item_info" IS E'放射線検査項目情報';
COMMENT ON COLUMN "mst_rad_set"."in_hospital_cd1" IS E'院内コード1';
COMMENT ON COLUMN "mst_rad_set"."sbt_cd1" IS E'属性コード1';
COMMENT ON COLUMN "mst_rad_set"."in_hospital_cd2" IS E'院内コード2';
COMMENT ON COLUMN "mst_rad_set"."sbt_cd2" IS E'属性コード2';
COMMENT ON COLUMN "mst_rad_set"."in_hospital_cd3" IS E'院内コード3';
COMMENT ON COLUMN "mst_rad_set"."sbt_cd3" IS E'属性コード3';
COMMENT ON COLUMN "mst_rad_set"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_rad_set"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_rad_set"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_rad_set"."up_date" IS E'更新日時';
