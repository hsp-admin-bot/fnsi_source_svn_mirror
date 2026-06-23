-- テーブル削除
DROP TABLE IF EXISTS pat_rad_main;
-- テーブル作成
CREATE TABLE pat_rad_main
(
    rad_result_cd bigserial NOT NULL, --システムで管理する一意な放射線検査結果コード
    pat_id bigint NOT NULL, --システムで管理する一意な患者ID
    facility_cd character varying(6) NOT NULL, --施設コード
    fn_pat_id character varying(12), --FNW+で管理する施設内の一意な患者ID
    reg_rad_date timestamp(3) NOT NULL, --登録時放射線検査日時
    reg_order_class character varying(1) DEFAULT '3' NOT NULL, --登録時放射線検査区分
    rad_status character varying(1) DEFAULT '0', --状況区分
    order_rad_set_info jsonb, --放射線検査依頼セット情報
    cop_order_no1 bigint, --連携オーダ番号１
    cop_order_no2 bigint, --連携オーダ番号２
    is_lock character varying(1), --依頼変更可否フラグ
    ind_user_id bigint, --指示者
    is_del character varying(1) DEFAULT '0', --削除フラグ
    reg_date timestamp(3), --登録日時
    reg_staff bigint, --登録スタッフ
    up_date timestamp(3), --更新日時
    up_staff bigint, --最終更新スタッフ

    CONSTRAINT unq_pat_rad_main_01 PRIMARY KEY (rad_result_cd)
)
WITH (
    OIDS=FALSE
);
-- コメント追加
COMMENT ON TABLE "pat_rad_main" IS E'患者放射線検査DB';
COMMENT ON COLUMN "pat_rad_main"."rad_result_cd" IS E'システムで管理する一意な放射線検査結果コード';
COMMENT ON COLUMN "pat_rad_main"."pat_id" IS E'システムで管理する一意な患者ID';
COMMENT ON COLUMN "pat_rad_main"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "pat_rad_main"."fn_pat_id" IS E'FNW+で管理する施設内の一意な患者ID';
COMMENT ON COLUMN "pat_rad_main"."reg_rad_date" IS E'登録時放射線検査日時';
COMMENT ON COLUMN "pat_rad_main"."reg_order_class" IS E'登録時放射線検査区分';
COMMENT ON COLUMN "pat_rad_main"."rad_status" IS E'状況区分';
COMMENT ON COLUMN "pat_rad_main"."order_rad_set_info" IS E'放射線検査依頼セット情報';
COMMENT ON COLUMN "pat_rad_main"."cop_order_no1" IS E'連携オーダ番号１';
COMMENT ON COLUMN "pat_rad_main"."cop_order_no2" IS E'連携オーダ番号２';
COMMENT ON COLUMN "pat_rad_main"."is_lock" IS E'依頼変更可否フラグ';
COMMENT ON COLUMN "pat_rad_main"."ind_user_id" IS E'指示者';
COMMENT ON COLUMN "pat_rad_main"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "pat_rad_main"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "pat_rad_main"."reg_staff" IS E'登録スタッフ';
COMMENT ON COLUMN "pat_rad_main"."up_date" IS E'更新日時';
COMMENT ON COLUMN "pat_rad_main"."up_staff" IS E'最終更新スタッフ';