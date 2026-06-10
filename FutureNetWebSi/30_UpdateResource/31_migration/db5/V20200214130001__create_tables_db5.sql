DROP TABLE IF EXISTS mst_mente_detail;

CREATE TABLE mst_mente_detail
(
    mente_detail_cd bigserial NOT NULL,
    facility_cd character varying(6) NOT NULL,
    mente_category_cd bigint,
    mente_content_1 character varying ,
    mente_content_2 character varying ,
    mente_content_3 character varying ,
    is_disp character varying(1) DEFAULT '1',
    is_del character varying(1) DEFAULT '0',
    up_date timestamp(3),
    reg_date timestamp(3),
    CONSTRAINT unq_mst_mente_detail_01 PRIMARY KEY (mente_detail_cd)
);

COMMENT ON TABLE "mst_mente_detail" IS E'日常・定期点検項目マスタ';
COMMENT ON COLUMN "mst_mente_detail"."mente_detail_cd" IS E'点検詳細品目コード';
COMMENT ON COLUMN "mst_mente_detail"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_mente_detail"."mente_category_cd" IS E'カテゴリコード';
COMMENT ON COLUMN "mst_mente_detail"."mente_content_1" IS E'内容１';
COMMENT ON COLUMN "mst_mente_detail"."mente_content_2" IS E'内容2';
COMMENT ON COLUMN "mst_mente_detail"."mente_content_3" IS E'内容3';
COMMENT ON COLUMN "mst_mente_detail"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_mente_detail"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_mente_detail"."up_date" IS E'更新日時';
COMMENT ON COLUMN "mst_mente_detail"."reg_date" IS E'登録日時';


DROP TABLE IF EXISTS mst_mente_category;

CREATE TABLE mst_mente_category
(
    mente_category_cd bigserial NOT NULL,
    facility_cd character varying(6) NOT NULL,
    category_name character varying(256) ,
    is_disp character varying(1) DEFAULT '1',
    is_del character varying(1) DEFAULT '0',
    up_date timestamp(3),
    reg_date timestamp(3),
    CONSTRAINT unq_mst_mente_category_01 PRIMARY KEY (mente_category_cd)
);

COMMENT ON TABLE "mst_mente_category" IS E'定期点検項目グループマスタ';
COMMENT ON COLUMN "mst_mente_category"."mente_category_cd" IS E'点検カテゴリコード';
COMMENT ON COLUMN "mst_mente_category"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_mente_category"."category_name" IS E'カテゴリー名';
COMMENT ON COLUMN "mst_mente_category"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_mente_category"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_mente_category"."up_date" IS E'更新日時';
COMMENT ON COLUMN "mst_mente_category"."reg_date" IS E'登録日時';

DROP TABLE IF EXISTS mst_mente_layout;

CREATE TABLE mst_mente_layout
(
    mente_layout_cd bigserial NOT NULL,
    facility_cd character varying(6) NOT NULL,
    layout_class character varying(1),
    layout_name character varying(265) ,
    type_info jsonb,
    detail_info_1 jsonb ,
    detail_info_2 jsonb ,
    is_disp character varying(1) DEFAULT '1',
    is_del character varying(1) DEFAULT '0',
    up_date timestamp(3),
    reg_date timestamp(3),
    CONSTRAINT unq_mst_mente_layout_01 PRIMARY KEY (mente_layout_cd)
);

COMMENT ON TABLE "mst_mente_layout" IS E'日常・定期点検レイアウトマスタ';
COMMENT ON COLUMN "mst_mente_layout"."mente_layout_cd" IS E'点検レイアウトコード';
COMMENT ON COLUMN "mst_mente_layout"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_mente_layout"."layout_class" IS E'レイアウトクラス';
COMMENT ON COLUMN "mst_mente_layout"."layout_name" IS E'レイアウト名';
COMMENT ON COLUMN "mst_mente_layout"."type_info" IS E'マシンタイプリスト';
COMMENT ON COLUMN "mst_mente_layout"."detail_info_1" IS E'詳細検査リスト1';
COMMENT ON COLUMN "mst_mente_layout"."detail_info_2" IS E'詳細検査リスト2';
COMMENT ON COLUMN "mst_mente_layout"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_mente_layout"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_mente_layout"."up_date" IS E'更新日時';
COMMENT ON COLUMN "mst_mente_layout"."reg_date" IS E'登録日時';


DROP TABLE IF EXISTS mst_mente_layout_group;

CREATE TABLE mst_mente_layout_group
(
    mente_layout_group_cd bigserial NOT NULL,
    facility_cd character varying(6) NOT NULL,
    group_name character varying(265) ,
    layout_default bigint NOT NULL,
    layout_list jsonb NOT NULL,
    is_disp character varying(1) DEFAULT '1',
    is_del character varying(1) DEFAULT '0',
    up_date timestamp(3),
    reg_date timestamp(3),
    CONSTRAINT unq_mst_mente_layout_group_01 PRIMARY KEY (mente_layout_group_cd)
);

COMMENT ON TABLE "mst_mente_layout_group" IS E'定期点検機種別レイアウトマスタ';
COMMENT ON COLUMN "mst_mente_layout_group"."mente_layout_group_cd" IS E'点検レイアウトグループコード';
COMMENT ON COLUMN "mst_mente_layout_group"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_mente_layout_group"."group_name" IS E'点検レイアウトグループ名';
COMMENT ON COLUMN "mst_mente_layout_group"."layout_default" IS E'デフォルトレイアウト';
COMMENT ON COLUMN "mst_mente_layout_group"."layout_list" IS E'レイアウトリスト';
COMMENT ON COLUMN "mst_mente_layout_group"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_mente_layout_group"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_mente_layout_group"."up_date" IS E'更新日時';
COMMENT ON COLUMN "mst_mente_layout_group"."reg_date" IS E'登録日時';

DROP TABLE IF EXISTS mnt_mente_main;

CREATE TABLE mnt_mente_main
(
    mente_no bigserial NOT NULL,
    facility_cd character varying(6) NOT NULL,
    mente_class character varying(1),
    machine_no bigint,
    rec_no int,
    mente_date date,
    mente_layout_group_cd bigint,
    mente_layout_cd bigint NOT NULL,
    checker_id_1 character varying,
    checker_id_2 character varying,
    mente_ans_1 character varying(1),
    mente_ans_2 character varying(1),
    mente_comment_1 character varying,
    mente_comment_2 character varying,
    detail jsonb,
    is_disp character varying(1) DEFAULT '1',
    is_del character varying(1) DEFAULT '0',
    up_date timestamp(3),
    reg_date timestamp(3),
    CONSTRAINT unq_mente_main_01 PRIMARY KEY (mente_no)
);

CREATE UNIQUE INDEX unq_mnt_mente_main_02
ON mnt_mente_main(machine_no, mente_layout_cd, mente_date)
WHERE is_del = '0';

COMMENT ON TABLE "mnt_mente_main" IS E'点検結果';
COMMENT ON COLUMN "mnt_mente_main"."mente_no" IS E'点検結果コード';
COMMENT ON COLUMN "mnt_mente_main"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mnt_mente_main"."mente_class" IS E'型式検査';
COMMENT ON COLUMN "mnt_mente_main"."machine_no" IS E'装置番号';
COMMENT ON COLUMN "mnt_mente_main"."rec_no" IS E'記録番号';
COMMENT ON COLUMN "mnt_mente_main"."mente_date" IS E'点検日';
COMMENT ON COLUMN "mnt_mente_main"."mente_layout_group_cd" IS E'点検レイアウトグループコード';
COMMENT ON COLUMN "mnt_mente_main"."mente_layout_cd" IS E'点検レイアウトコード';
COMMENT ON COLUMN "mnt_mente_main"."checker_id_1" IS E'点検実施者';
COMMENT ON COLUMN "mnt_mente_main"."checker_id_2" IS E'確認者';
COMMENT ON COLUMN "mnt_mente_main"."mente_ans_1" IS E'結果入力パターン1';
COMMENT ON COLUMN "mnt_mente_main"."mente_ans_2" IS E'結果入力パターン2';
COMMENT ON COLUMN "mnt_mente_main"."mente_comment_1" IS E'定期検査記録コメント';
COMMENT ON COLUMN "mnt_mente_main"."mente_comment_2" IS E'定期交換部品記録コメント';
COMMENT ON COLUMN "mnt_mente_main"."detail" IS E'内容';
COMMENT ON COLUMN "mnt_mente_main"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mnt_mente_main"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mnt_mente_main"."up_date" IS E'更新日時';
COMMENT ON COLUMN "mnt_mente_main"."reg_date" IS E'登録日時';


